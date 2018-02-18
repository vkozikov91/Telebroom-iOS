//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import ObjectMapper
import RealmSwift

enum MessageType: Int {
    case text, image, deleted
}

class Message: Object, Mappable {
    
    private static let mongoDateFormatter = DateFormatter.initWithMongoFormat()
    private static let timeStampDateFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.zeroFormattingBehavior = .dropAll
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute]
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "en")
        formatter.calendar = calendar
        return formatter
    }()
    
    static let serviceSymbols = ">>"
    
    @objc dynamic var id: String?
    @objc dynamic var text: String!
    @objc dynamic var from: String!
    @objc dynamic var to: String!
    @objc dynamic var timeStamp: Date!
    @objc dynamic var isIncoming: Bool = false
    
    var type: MessageType! {
        get { return MessageType(rawValue: _typeRaw) }
        set { _typeRaw = newValue.rawValue }
    }
    @objc dynamic var _typeRaw = 0 // Workaround since Realm doesn't support enums at the moment
    
    
    // MARK: -
    
    var imageUrl: URL? {
        // image message text has 'img>>eifai277FQuweiua.jpg' format
        let components = self.text.components(separatedBy: Message.serviceSymbols)
        guard components.count == 2, components.first! == "img" else { return nil }
        return URL(string: Constants.SERVER_API_ADDRESS + "/images/" + components.last!)
    }
    
    var timeStampISOString: String {
        return Message.mongoDateFormatter.string(from: self.timeStamp)
    }
    
    var isTextMessage: Bool {
        return self.type == .text
    }
    
    var timePassed: String {
        let now = Date()
        let components = Calendar.current.dateComponents([.minute], from: self.timeStamp, to: now)
        guard let minutes = components.minute, minutes > 0 else { return "Just now" }
        let timeString = Message.timeStampDateFormatter.string(from: self.timeStamp , to: now)
        return String(format: "%@ ago", timeString!)
    }
    
    var shortFormatText: String {
        switch self.type! {
        case .deleted:
            return "* Deleted message *"
        case .image:
            return "* Image *"
        default:
            return self.text
        }
    }
    
    private var isDeleted: Bool {
        // deleted message text has 'dlt>>' format
        let components = self.text.components(separatedBy: Message.serviceSymbols)
        return (components.count == 2 && components.first == "dlt")
    }
    
    
    // MARK: - Mappable
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        text <- map["text"]
        from <- map["from"]
        to <- map["to"]
        
        var date: String!
        date <- map["date"]
        timeStamp = Message.mongoDateFormatter.date(from: date!)!
    }
    
    
    // MARK: - Realm
    
    override static func ignoredProperties() -> [String] {
        return ["type", "imageUrl", "timeStampISOString", "isTextMessage", "isDeleted"]
    }
    
    
    // MARK: -
    
    func setAsDeleted() {
        self.type = .deleted
        self.text = "dlt\(Message.serviceSymbols)"
    }
    
    func defineDirection(localUserName: String) {
        self.isIncoming = (self.from != localUserName)
    }
    
    func defineDirection(remoteUserName: String) {
        self.isIncoming = (self.from == remoteUserName)
    }
    
    func defineType() {
        if self.imageUrl != nil {
            self.type = .image
        } else if self.isDeleted {
            self.type = .deleted
        } else {
            self.type = .text
        }
    }
    
    class func extract(from data: Any, localUserName: String) -> Message? {
        guard let jsonData = data as? Dictionary<String, Any> else { return nil}
        let msg = Message(JSON: jsonData)
        msg?.defineDirection(localUserName: localUserName)
        msg?.defineType()
        return msg
    }
    
}
