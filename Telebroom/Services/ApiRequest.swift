//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import Foundation
import Alamofire

enum ApiRequest {
    
    case login(username: String, password: String)
    case signup(username: String, password: String, firstname: String, secondname: String)
    case verifyToken(token: String)
    //
    case getContacts
    case checkOnline(remoteUser: String)
    case addToContacts(remoteUser: String)
    case verifyContact(remoteUser: String)
    case removeFromContacts(remoteUser: String)
    case changeUserInfo(firstname: String, secondname: String)
    //
    case getMessages(remoteUser: String, fromDate: String, pageSize: Int)
    case sendMessage(remoteUser: String, text: String)
    case sendImage(remoteUser: String)
    case deleteMessages(remoteUser: String, ids: [String])
    //
    case search(query: String)
    //
    case registerPushToken(token: String, username: String)
    case invalidatePushToken(username: String)
    //
    case uploadAvatar
    //
    case ping
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .addToContacts, .verifyContact, .changeUserInfo, .registerPushToken, .invalidatePushToken:
            return .patch
        case .sendMessage, .sendImage, .signup:
            return .post
        case .removeFromContacts, .deleteMessages:
            return .delete
        default:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .verifyToken:
            return "/verifySession"
        case .login:
            return "/login"
        case .signup:
            return "/signup"
        //
        case .getContacts:
            return "/users/getContacts"
        case .checkOnline:
            return "/users/getIsOnline"
        case .addToContacts:
            return "/users/addContact"
        case .verifyContact:
            return "/users/verifyContact"
        case .removeFromContacts:
            return "/users/removeContact"
        case .changeUserInfo:
            return "/users/changeUserInfo"
        //
        case .getMessages:
            return "/messages"
        case .sendMessage:
            return "/messages/text"
        case .sendImage:
            return "/messages/image"
        case .deleteMessages:
            return "/messages/delete"
        //
        case .search:
            return "/users/search"
        //
        case .registerPushToken:
            return "/users/registerPushToken"
        case .invalidatePushToken:
            return "/users/unregisterPushToken"
        //
        case .uploadAvatar:
            return "/users/avatar"
        //
        case .ping:
            return "/ping"
        }
    }
    
    var params: [String: Any]? {
        switch self {
            
        case .verifyToken(let token):
            return ["token": token]
            
        case .login(let username, let password):
            return ["username": username,
                    "password": password]
            
        case .signup(let username, let password, let firstname, let secondname):
            return ["username": username,
                    "password": password,
                    "firstname": firstname,
                    "secondname": secondname]
            
            //
            
        case .checkOnline(let remoteUser):
            return ["username": remoteUser]
            
        case .addToContacts(let remoteUser):
            return ["contact": remoteUser]
            
        case .verifyContact(let remoteUser):
            return ["contact": remoteUser]
            
        case .removeFromContacts(let remoteUser):
            return ["contact": remoteUser]
            
        case .changeUserInfo(let firstname, let secondname):
            return ["firstname": firstname,
                    "secondname": secondname]
            
            //
            
        case .getMessages(let remoteUser, let fromDate, let pageSize):
            return ["remoteUser": remoteUser,
                    "fromDate": fromDate,
                    "pageSize": pageSize]
            
        case .sendMessage(let remoteUser, let text):
            return ["remoteUser": remoteUser,
                    "text": text]
            
        case .sendImage(let remoteUser):
            return ["remoteUser": remoteUser,
                    "name": "avatar",
                    "filename": "avatar.jpg",
                    "mimeType": "image/jpg"]
            
        case .deleteMessages(let remoteUser, let ids):
            return ["remoteUser": remoteUser,
                    "ids": ids]
            
            //
            
        case .search(let query):
            return ["query": query]
            
            //
        
        case .registerPushToken(let token, let username):
            return ["pushToken": token,
                    "username": username]
            
        case .invalidatePushToken(let username):
            return ["username": username]
            
            //
            
        case .uploadAvatar:
            return ["name": "avatar",
                    "filename": "avatar.jpg",
                    "mimeType": "image/jpg"]
            
        default:
            return nil
        }
    }
    
    var requiresAuth: Bool {
        switch self {
        case .ping, .verifyToken, .login, .signup:
            return false
        default:
            return true
        }
    }
    
    func asURL() -> URL {
        let requestFullPath = (self.requiresAuth ? ContentApi.authorizedApiAddress : ContentApi.publicApiAddress) + self.path
        return URL(string: requestFullPath)!
    }
    
}
