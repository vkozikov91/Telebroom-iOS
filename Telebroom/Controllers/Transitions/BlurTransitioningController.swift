//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

class BlurTransitioningController: NSObject, UIViewControllerTransitioningDelegate {
    
    private var presenting = false
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = false
        return self
    }
}

extension BlurTransitioningController: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Constants.transitions.BLUR_NAVIGATION_TRANSITION_DURATION
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.presenting ? performPresentTransition(in: transitionContext)
            : performDismissTransition(in: transitionContext)
    }
    
    func performPresentTransition(in context: UIViewControllerContextTransitioning) {
        let container = context.containerView
        let fromView = context.viewController(forKey: UITransitionContextViewControllerKey.from)!.view!
        let toView = context.viewController(forKey: UITransitionContextViewControllerKey.to)!.view!
        
        fromView.frame = container.frame
        toView.frame = container.frame
        
        let overlayBlurView = UIVisualEffectView()
        overlayBlurView.frame = container.frame

        container.addSubview(fromView)
        container.addSubview(overlayBlurView)
        
        let halfTransitionInterval = self.transitionDuration(using: context) / 2
        
        UIView.animate(
            withDuration: halfTransitionInterval,
            animations: { overlayBlurView.effect = UIBlurEffect(style: UIBlurEffectStyle.extraLight) },
            completion: { _ in
                container.insertSubview(toView, belowSubview: overlayBlurView)
                UIView.animate(
                    withDuration: halfTransitionInterval,
                    animations: { overlayBlurView.effect = nil },
                    completion: { _ in
                        overlayBlurView.removeFromSuperview()
                        context.completeTransition(true)
                    })
            }
        )
    }
    
    func performDismissTransition(in context: UIViewControllerContextTransitioning) {
        let container = context.containerView
        let fromView = context.viewController(forKey: UITransitionContextViewControllerKey.from)!.view!
        let toView = context.viewController(forKey: UITransitionContextViewControllerKey.to)!.view!
        
        fromView.frame = container.frame
        toView.frame = container.frame
        
        let overlayBlurView = UIVisualEffectView()
        overlayBlurView.frame = container.frame
        
        container.addSubview(toView)
        container.addSubview(fromView)
        container.addSubview(overlayBlurView)
        
        let halfTransitionInterval = self.transitionDuration(using: context) / 2
        
        UIView.animate(
            withDuration: halfTransitionInterval,
            animations: { overlayBlurView.effect = UIBlurEffect(style: UIBlurEffectStyle.extraLight) },
            completion: { _ in
                fromView.removeFromSuperview()
                UIView.animate(
                    withDuration: halfTransitionInterval,
                    animations: { overlayBlurView.effect = nil },
                    completion: { _ in
                        overlayBlurView.removeFromSuperview()
                        context.completeTransition(true)
                })
        }
        )
    }
    
}
