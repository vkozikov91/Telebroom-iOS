//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

class DissolveTransitioningController: NSObject, UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}

extension DissolveTransitioningController: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Constants.transitions.SCALE_DISSOLVE_TRANSITION_DURATION
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let fromView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!.view!
        let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!.view!
        
        fromView.frame = container.frame
        toView.frame = container.frame
        
        container.addSubview(fromView)
        
        toView.alpha = 0.0
        toView.layoutIfNeeded()
        container.addSubview(toView)
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            toView.alpha = 1.0
        }) { _ in
            transitionContext.completeTransition(true)
        }
        
    }
}
