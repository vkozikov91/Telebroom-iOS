//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit
import SnapKit

extension UIViewController {
    func showActivityIndicator() {
        self.view.isUserInteractionEnabled = false
        navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = false }
        ActivityIndicatorContainerView.show(in: self)
    }
    func hideActivityIndicator() {
        self.view.isUserInteractionEnabled = true
        navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = true }
        ActivityIndicatorContainerView.hide(in: self)
    }
}

private class ActivityIndicatorContainerView: UIView {
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    private let containerSize = CGSize(width: 80, height: 80)
    private let containerView = UIView()
    
    override var intrinsicContentSize: CGSize {
        return containerSize
    }
    
    class func show(in controller: UIViewController) {
        let aiCV = ActivityIndicatorContainerView()
        controller.view.addSubview(aiCV)
        aiCV.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        aiCV.appearAnimated()
    }
    
    class func hide(in controller: UIViewController) {
        let aiCV = controller.view.subviews.first { $0 is ActivityIndicatorContainerView } as! ActivityIndicatorContainerView
        aiCV.disappearAnimated()
    }
    
    private init() {
        super.init(frame: CGRect(origin: CGPoint.zero, size: containerSize))
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func appearAnimated() {
        self.alpha = 0.0
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.5) { self.alpha = 1.0 }
    }
    
    private func disappearAnimated() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: { 
            self.alpha = 0.0
        }) { (completed) in
            self.removeFromSuperview()
        }
    }
    
    private func setupView() {
        self.backgroundColor = UIColor.clear
        
        self.addSubview(containerView)
        containerView.backgroundColor = UIColor.black
        containerView.alpha = 0.45
        containerView.layer.cornerRadius = 15.0
        containerView.clipsToBounds = true
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
