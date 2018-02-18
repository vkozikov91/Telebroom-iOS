//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

class PushNotificationsService: BaseService {
    
    func registerForPushNotifications() {
        let notificationTypes: UIUserNotificationType = [.alert, .badge, .sound]
        let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        let application = UIApplication.shared
        application.registerUserNotificationSettings(pushNotificationSettings)
        application.registerForRemoteNotifications()
    }
    
    func handleRegistrationSuccess(deviceToken: Data) {
        guard let username = self.repository.localUser?.username else {
            print("[!] Trying to register push token for undefined local user")
            return
        }
        let token = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        contentApi.request(ApiRequest.registerPushToken(token: token, username: username))
            .catch { error in  }
    }
    
    func handleRegistrationFailure(error: Error) {
        print("[!] Failed to register for Push Notifications: ", error.localizedDescription)
    }
    
    func invalidateTokenAndUnsubscribePushNotifications() {
        UIApplication.shared.unregisterForRemoteNotifications()
        guard let username = self.repository.localUser?.username else {
            print("[!] Trying to invalidate push token for undefined local user")
            return
        }
        contentApi.request(ApiRequest.invalidatePushToken(username: username))
            .catch { error in  }
    }
    
}
