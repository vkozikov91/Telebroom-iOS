//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    private let blurTransitioning = BlurTransitioningController()
    private let dissolveTransitioning = DissolveTransitioningController()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
    }
    
    func unwindToLoginOrRoot() {
        var loginVC: UIViewController?
        self.viewControllers.forEach { ($0 is LoginViewController) ? loginVC = $0 : () }
        if loginVC == nil {
            self.popToRootViewController(animated: true)
        } else {
            self.popToViewController(loginVC!, animated: true)
        }
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationControllerOperation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromVC is IntroViewController && toVC is LoginViewController {
            return self.dissolveTransitioning
        } else {
            return self.blurTransitioning
        }
    }
}
