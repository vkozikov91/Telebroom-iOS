//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import ObjectMapper
import RxCocoa
import RxSwift
import RealmSwift

class RemoteUserViewModel: Object, Mappable {
    
    @objc dynamic var username = ""
    @objc dynamic var firstname = ""
    @objc dynamic var secondname = ""
    @objc dynamic var imageUrl = ""
    @objc dynamic var verified = false
    private var _messages = List<Message>([])
    var messages: [Message] {
         // Workaround since Realm objects don't support didSet
        get { return _messages.map { $0 } }
        set {
            _messages.removeAll()
            _messages.append(objectsIn: newValue)
            self.lastMessage.value = messages.first
        }
    }
    
    var isOnline = Variable<Bool>(false)
    var hasUnreadMessages = Variable<Bool>(false)
    var lastMessage = Variable<Message?>(nil)
    
    var fullName: String {
        if !firstname.isEmpty && !secondname.isEmpty {
            return "\(firstname) \(secondname)"
        } else if !firstname.isEmpty {
            return "\(firstname) (\(username))"
        } else {
            return username
        }
    }
    
    var fullImageUrl: URL? {
        guard !self.imageUrl.isEmpty else { return nil }
        return URL(string: Constants.SERVER_API_ADDRESS + imageUrl)
    }
    
    func refreshLastMessageTextAndDate() {
        guard self.verified else { return }
        self.lastMessage.value = self.lastMessage.value
    }
    
    // MARK: - Realm
    
    override static func ignoredProperties() -> [String] {
        return ["repository",
                "messages",
                "isOnline",
                "hasUnreadMessages",
                "lastMessage",
                "fullName",
                "fullImageUrl"]
    }
    
    override class func primaryKey() -> String? {
        return "username"
    }
    
    // MARK: - Mappable
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        username <- map["username"]
        firstname <- map["firstname"]
        secondname <- map["secondname"]
        imageUrl <- map["imageUrl"]
        verified <- map["verified"];
        isOnline.value <- map["isOnline"]
    }
}
