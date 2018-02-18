//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import ObjectMapper
import RealmSwift

class LocalUser: Object, Mappable {
    
    @objc dynamic var username = ""
    @objc dynamic var firstname = ""
    @objc dynamic var secondname = ""
    @objc dynamic var imageUrl = ""
    
    var token = "" // Stored in Keychain
    
    var fullImageUrl: URL? {
        guard !self.imageUrl.isEmpty else { return nil }
        return URL(string: Constants.SERVER_API_ADDRESS + imageUrl)
    }

    // MARK: - Realm
    
    override static func ignoredProperties() -> [String] {
        return ["fullImageUrl", "token"]
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
        token <- map["token"]
    }
    
}
