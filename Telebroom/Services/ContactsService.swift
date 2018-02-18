//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import Foundation
import PromiseKit

class ContactsService: BaseService {
    
    func getContacts() -> Promise<[RemoteUserViewModel]> {
        return contentApi.request(ApiRequest.getContacts)
    }
    
    func addToContacts(_ username: String) -> Promise<Void> {
        return contentApi.request(ApiRequest.addToContacts(remoteUser: username)).asVoid()
    }
    
    func verifyContact(_ username: String) -> Promise<Void> {
        return contentApi.request(ApiRequest.verifyContact(remoteUser: username)).asVoid()
    }
    
    func removeFromContacts(_ username: String) -> Promise<Void> {
        return contentApi.request(ApiRequest.removeFromContacts(remoteUser: username)).asVoid()
    }
    
    func checkIsOnline(_ username: String) -> Promise<Bool> {
        let r = ApiRequest.checkOnline(remoteUser: username)
        return contentApi.request(r).then { $0.toBool() }
    }
    
}
