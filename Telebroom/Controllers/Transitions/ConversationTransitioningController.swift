//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

class ConversationTransitioningController: NSObject, UIViewControllerTransitioningDelegate {
    
    private var presenting = false
    
    private var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return view
    }()
    
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

extension ConversationTransitioningController: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.presenting ? Constants.transitions.CONVERSATION_TRANSITION_APPEAR_DURATION :
            Constants.transitions.CONVERSATION_TRANSITION_DISAPPEAR_DURATION
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
        overlayView.frame = container.frame
        
        container.addSubview(overlayView)
        container.addSubview(toView)
        
        toView.frame.origin = CGPoint(x: 0.0, y: UIScreen.main.bounds.height)
        toView.backgroundColor = UIColor.clear
        overlayView.alpha = 0.0
        
        UIView.animate(withDuration: self.transitionDuration(using: context),
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseOut,
                       animations: {
            toView.frame.origin = CGPoint.zero
            self.overlayView.alpha = 1.0
            // fromView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { (finished) in
            context.completeTransition(true)
        }
    
    }
    
    func performDismissTransition(in context: UIViewControllerContextTransitioning) {
        let container = context.containerView
        let fromView = context.viewController(forKey: UITransitionContextViewControllerKey.from)!.view!
        let toView = context.viewController(forKey: UITransitionContextViewControllerKey.to)!.view!
        
        fromView.frame = container.frame
        toView.frame = container.frame
        
        //container.addSubview( toView )
        //container.addSubview( fromView )
        
        UIView.animate(withDuration: self.transitionDuration(using: context), animations: {
            fromView.frame.origin = CGPoint(x: 0.0, y: UIScreen.main.bounds.height)
            self.overlayView.alpha = 0.0
            // toView.transform = CGAffineTransform.identity
        }) { (finished) in
            self.overlayView.removeFromSuperview()
            context.completeTransition(true)
        }
    }
    
}
