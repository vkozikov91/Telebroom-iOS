//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import ObjectMapper

class Status: Mappable {
    
    var username: String!
    var isOnline: Bool!
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        username <- map["username"]
        var onlineString: NSString = ""
        onlineString <- map["online"]
        isOnline = onlineString.boolValue
    }
    
    class func extract(from data: Any) -> Status? {
        guard let jsonData = data as? Dictionary<String, String> else { return nil}
        return Status(JSON: jsonData)
    }
    
}
