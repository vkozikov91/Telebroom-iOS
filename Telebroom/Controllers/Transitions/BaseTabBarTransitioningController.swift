//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

class BaseTabBarTransitioningController: NSObject {
    
    private var leftAnimation = true
    
    func willAnimateToLeft() {
        self.leftAnimation = true
    }
    
    func willAnimateToRight() {
        self.leftAnimation = false
    }
}

extension BaseTabBarTransitioningController: UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Constants.transitions.TAB_TRANSITION_DURATION
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        fromView.frame = container.frame
        toView.frame = container.frame
        
        let gradient = ThemeGradientView(frame: container.frame)
        ///gradient.inclinationType = self.leftAnimation ? 2 : 1
        
        container.backgroundColor = Theme.mainBackgroundColor
        container.addSubview(gradient)
        container.addSubview(fromView)
        container.addSubview(toView)
        
        let offset: CGFloat = 0.0
        let directionOffset = leftAnimation ? offset : -offset
        
        toView.alpha = 0.0
        toView.frame.origin = CGPoint(x: directionOffset, y: 0.0)
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            fromView.frame.origin = CGPoint(x: -directionOffset, y: 0.0)
            fromView.alpha = 0.0
            toView.frame.origin = CGPoint.zero
            toView.alpha = 1.0
        }) { (finished) in
            transitionContext.completeTransition(true)
            fromView.frame.origin = CGPoint.zero
            toView.frame.origin = CGPoint.zero
            gradient.removeFromSuperview()
        }
    }
    
}
