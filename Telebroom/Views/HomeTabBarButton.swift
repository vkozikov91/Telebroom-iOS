//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

class HomeTabBarButton: UIButton {
    
    let kHasUnreadMessagesViewSize: CGSize = CGSize(width: 7, height: 7)
    
    private let bubbleLayer = CAShapeLayer()
    private lazy var unreadMessagesView = {
        return PopUpView(frame: CGRect(origin: CGPoint.zero,size: kHasUnreadMessagesViewSize))
    }()
    
    // MARK: - Super
    
    override var isSelected: Bool {
        willSet(value) {
            guard value != self.isSelected else { return }
            animateBubbleLayer(forward: value)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateBubbleLayerFrame()
        self.layer.cornerRadius = self.frame.height / 2
    }
    
    // MARK: - Public
    
    public func showUnreadMessageIcon() {
        self.unreadMessagesView.appear()
    }
    
    public func hideUnreadMessageIcon() {
        self.unreadMessagesView.disappear()
    }
    
    // MARK: - Private
    
    private func setup() {
        self.clipsToBounds = true
        self.backgroundColor = Theme.inactiveButtonColor
        self.tintColor = UIColor.white
        self.bubbleLayer.fillColor = Theme.mainColor.cgColor
        
        self.unreadMessagesView.backgroundColor = UIColor.white
        self.addSubview(self.unreadMessagesView)
        self.unreadMessagesView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
            make.height.width.equalTo(kHasUnreadMessagesViewSize)
        }
        self.unreadMessagesView.disappear()
    }
    
    private func updateBubbleLayerFrame() {
        self.bubbleLayer.frame = self.bounds
        self.bubbleLayer.path = UIBezierPath(ovalIn: self.bounds).cgPath
        self.layer.insertSublayer(self.bubbleLayer, at: 0)
    }
    
    private func animateBubbleLayer(forward: Bool) {
        UIView.animate(withDuration: Constants.transitions.TAB_TRANSITION_DURATION) {
            self.bubbleLayer.transform = forward ? CATransform3DIdentity : CATransform3DMakeScale(0.1, 0.1, 0.1)
            self.bubbleLayer.opacity = forward ? 1.0 : 0.0
        }
    }
    
}
