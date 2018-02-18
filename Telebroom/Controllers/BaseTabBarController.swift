//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

class BaseTabBarController: UITabBarController, Routable {
    
    var router: AppRouter! {
        didSet {
            self.injectRouterToControllers()
            self.router.tabBarController = self
        }
    }
    
    private var currentError: ApiError?
    private var errorHandledCompletion: VoidClosure?
    
    private let tabTransitioningController = BaseTabBarTransitioningController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTabBar()
        self.goToHomeTab()
        self.delegate = self
    }
        
    private func goToHomeTab() {
        self.selectedIndex = TelebroomBottomBarTab.home.rawValue
    }
    
    private func configureTabBar() {
        UITabBar.appearance().tintColor = UIColor.clear
        self.tabBar.isTranslucent = true
        self.tabBar.items?.forEach { item in
            item.image = nil
            item.selectedImage = nil
        }
        let bar = self.tabBar as! TelebroomTabBar
        bar.tabSelectedDelegate = self
    }
    
    private func injectRouterToControllers() {
        self.viewControllers?.forEach( { (controller) in
            if let navigationController = controller as? UINavigationController {
                guard navigationController.topViewController! is Routable else { return }
                var destinationVC = navigationController.topViewController! as! Routable
                destinationVC.router = self.router
            } else {
                var destinationVC = controller as! Routable
                destinationVC.router = self.router
            }
        })
    }
    
    deinit {
        print("- \(String(describing: type(of: self))) dealloc")
    }
    
}

// MARK: -

extension BaseTabBarController: TelebroomBarTabSelectedDelegate {
    func onTabSelected(tab: TelebroomBottomBarTab) {
        self.selectedIndex = tab.rawValue
        UIApplication.shared.statusBarStyle = (tab != .profile) ? .lightContent : .default
    }
}

// MARK: -

extension BaseTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController,
                          animationControllerForTransitionFrom fromVC: UIViewController,
                          to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromVC.tabBarItem.tag > toVC.tabBarItem.tag {
            self.tabTransitioningController.willAnimateToRight()
        } else {
            self.tabTransitioningController.willAnimateToLeft()
        }
        return self.tabTransitioningController
    }
}
