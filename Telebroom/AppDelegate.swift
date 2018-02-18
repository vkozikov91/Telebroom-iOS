//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit
import UserNotifications
import AlamofireNetworkActivityIndicator

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appRouter: AppRouter!
    private var pushNotificationsService: PushNotificationsService!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let rootVC = AppBootstrapper.getInitialViewController()
        self.appRouter = rootVC.router
        self.pushNotificationsService = self.appRouter.serviceFactory.getPushNotificationsService()
        
        window?.rootViewController = rootVC.navigationController
        window?.makeKeyAndVisible()
        
        let navBarStyle = UINavigationBar.appearance()
        navBarStyle.barStyle = .black
        navBarStyle.barTintColor = Theme.mainColor
        navBarStyle.tintColor = Theme.mainBackgroundColor
        navBarStyle.isTranslucent = false
        navBarStyle.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Theme.mainBackgroundColor,
                                           NSAttributedStringKey.font: Theme.mainFont(18.0, bold: true)]
        
        NetworkActivityIndicatorManager.shared.isEnabled = true
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) { }

    func applicationDidEnterBackground(_ application: UIApplication) { }

    func applicationWillEnterForeground(_ application: UIApplication) { }

    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) { }
    
    
    // MARK: - Push Notifications
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.pushNotificationsService.handleRegistrationSuccess(deviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        self.pushNotificationsService.handleRegistrationFailure(error: error)
    }
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let remoteUser = userInfo["from"] as? String else { return }
        self.appRouter.appBus.pendingConversationUsername = remoteUser
        self.appRouter.openPendingConversationIfNeeded()
    }    
}
