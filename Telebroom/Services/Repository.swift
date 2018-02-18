//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import Foundation
import RealmSwift
import Locksmith

class Repository {
    
    private let kLocksmithUserAccount = "SchmypeUser"
    private var realm = try! Realm()
    
    var localUser: LocalUser? {
        didSet { self.saveLocalUser() }
    }
    
    init() {
        self.localUser = realm.objects(LocalUser.self).first
        if self.localUser != nil {
            let keychainData = Locksmith.loadDataForUserAccount(userAccount:self.kLocksmithUserAccount)!
            self.localUser!.token = keychainData["token"] as! String
        }
    }
    
    // MARK: - Realm Operations
    
    func performInRealm(_ closure: VoidClosure) {
        try? realm.write { closure() }
    }
    
    func saveLocalUser() {
        try? realm.write {
            if let user = self.localUser {
                realm.add(user, update: true)
                try? Locksmith.updateData(data: ["token": user.token],
                                          forUserAccount: self.kLocksmithUserAccount)
                // Just to ensure that user is not duplicated
                for savedUser in realm.objects(LocalUser.self) {
                    savedUser.username != self.localUser!.username ? realm.delete(savedUser) : ()
                }
            } else {
                realm.deleteAll()
                try? Locksmith.deleteDataForUserAccount(userAccount: self.kLocksmithUserAccount)
            }
        }
    }
    
    func updateLocalContacts(with users: [RemoteUserViewModel]) {
        /*
         * The following logic is needed since forced replacing objects saved in Realm with new users
         * may invalidate objects that are still in use. Thus this 'merging' is needed.
         */
        let newContactsListUsernames = users.map { $0.username }
        let oldContacts = realm.objects(RemoteUserViewModel.self)
        try? realm.write {
            realm.add(users, update: true)
            for oldContact in oldContacts {
                guard !newContactsListUsernames.contains(oldContact.username) else { continue }
                realm.delete(oldContact)
            }
        }
    }
    
    func saveLocalContact(_ user: RemoteUserViewModel) {
        try? realm.write { realm.add(user, update: true) }
    }
    
    func deleteLocalContact(_ user: RemoteUserViewModel) {
        guard let localCopy = realm.objects(RemoteUserViewModel.self).filter("username = '\(user.username)'").first
            else { return }
        try? realm.write { realm.delete(localCopy) }
    }
    
    func loadLocalContacts() -> [RemoteUserViewModel]? {
        return Array(self.realm.objects(RemoteUserViewModel.self))
    }
    
}
