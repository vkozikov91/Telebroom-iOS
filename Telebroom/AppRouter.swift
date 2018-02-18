//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

protocol Routable {
    var router: AppRouter! { get set }
}

class AppRouter {
    
    var serviceFactory: ServiceFactory
    var vmFactory: ViewModelFactory
    var appBus: AppBus
    weak var mainNavigationController: MainNavigationController?
    weak var tabBarController: BaseTabBarController?
    
    init() {
        let repo = Repository()
        self.serviceFactory = ServiceFactory(repository: repo)
        self.vmFactory = ViewModelFactory(serviceFactory: self.serviceFactory, repository: repo)
        self.appBus = AppBus()
    }
    
    func openPendingConversationIfNeeded() {
        guard let tbController = tabBarController, let contactsVC = getContactsViewController()
            else { return }
        tbController.selectedIndex = TelebroomBottomBarTab.home.rawValue
        contactsVC.openPendingConversationIfNeeded()
    }
    
    func resetApp() {
        self.appBus.clearBus()
        self.vmFactory.reset()
        UIApplication.shared.statusBarStyle = .lightContent
        self.mainNavigationController?.unwindToLoginOrRoot()
    }
    
    private func getContactsViewController() -> ContactsViewController? {
        guard let vc = tabBarController?.viewControllers?[TelebroomBottomBarTab.home.rawValue],
            let navVC = vc as? UINavigationController
            else { return nil }
        return navVC.viewControllers.first as? ContactsViewController
    }
    
}
