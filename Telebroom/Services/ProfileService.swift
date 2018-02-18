//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit
import PromiseKit
import Alamofire
import AlamofireObjectMapper
import CryptoSwift

class ProfileService: BaseService {
    
    private var wscService: WSConnectionService!
    private var pushNotificationsService: PushNotificationsService!
    
    // MARK: - Public
    
    var canAutoLogin: Bool { return (repository.localUser != nil) }
    
    func inject(_ wscService: WSConnectionService, _ pushService: PushNotificationsService) -> Self {
        self.wscService = wscService
        self.pushNotificationsService = pushService
        return self
    }
    
    func tryAutoLogin() -> Promise<Void> {        
        return Promise { fulfill, reject in
            firstly { self.verifyToken(self.repository.localUser!.token) }
                .then { return self.connectWSCService() }
                .then { self.pushNotificationsService.registerForPushNotifications() }
                .then { fulfill(()) }
                .catch { error in reject(error) }
        }
    }
    
    func login(username: String, password: String) -> Promise<Void> {
        return loginUser(username:username, password:password)
            .then { self.repository.localUser = $0 }
            .then { return self.connectWSCService() }
            .then { self.pushNotificationsService.registerForPushNotifications() }
    }
    
    func signup(username: String, password: String, firstName: String?, secondName: String?) -> Promise<Void> {
        return signupUser(username: username,
                          password: password,
                          firstName: firstName ?? "",
                          secondName: secondName ?? "")
            .then { self.repository.localUser = $0 }
            .then { return self.connectWSCService() }
            .then { self.pushNotificationsService.registerForPushNotifications() }
    }
    
    func changeUserInfo(firstname: String, secondname: String) -> Promise<Void> {
        let r = ApiRequest.changeUserInfo(firstname: firstname, secondname: secondname)
        return contentApi.request(r)
            .then { _ in
                self.repository.performInRealm {
                    self.repository.localUser?.firstname = firstname
                    self.repository.localUser?.secondname = secondname
                }
            }
    }
    
    func uploadAvatar(_ image: UIImage) -> Promise<Void> {
        return contentApi.upload(ApiRequest.uploadAvatar, data: UIImageJPEGRepresentation(image, 0.5)!)
            .then(execute: extractImageURLFromResponse)
            .then(execute: updateLocalUserImageURL)
    }
    
    func logout() {
        self.contentApi.stopAllRequests()
        self.wscService.disconnect()
        self.pushNotificationsService.invalidateTokenAndUnsubscribePushNotifications()
        self.repository.localUser = nil
    }
    
    
    // MARK: - Private
    
    private func loginUser(username: String, password: String) -> Promise<LocalUser> {
        return contentApi.request(ApiRequest.login(username: username, password: password.sha1()))
    }
    
    private func signupUser(username: String, password: String,
                            firstName: String, secondName: String) -> Promise<LocalUser> {
        return contentApi.request(ApiRequest.signup(username: username,
                                                    password: password.sha1(),
                                                    firstname: firstName,
                                                    secondname: secondName))
    }
    
    private func verifyToken(_ token: String) -> Promise<Void> {
        return contentApi.request(ApiRequest.verifyToken(token: token)).asVoid()
    }
    
    private func extractImageURLFromResponse(_ response: Any) -> Promise<String> {
        return Promise { fulfill, reject in
            guard let json = response as? Dictionary<String, String>,
                let imageUrl = json["imageUrl"]
            else {
                reject(NSError.defaultError)
                return
            }
            fulfill(imageUrl)
        }
    }
    
    private func updateLocalUserImageURL(_ urlString: String) {
        self.repository.performInRealm {
            self.repository.localUser?.imageUrl = urlString
        }
        self.repository.saveLocalUser()
    }
    
    private func connectWSCService() -> Promise<Void> {
        return Promise { fulfill, reject in
            wscService.connect { (success) in
                success ? fulfill(()) : reject(ApiError.serverUnreachable)
            }
        }
    }
    
}
