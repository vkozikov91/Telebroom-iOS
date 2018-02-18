//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

class BubbleButton: UIButton {
    
    private var bubbleLayer = CAShapeLayer()

    // MARK: - Super
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupButton()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.updateBubbleLayerFrame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.playTouchAnimation()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.playReleaseAnimation()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.playReleaseAnimation()
    }
    
    override var isSelected: Bool {
        willSet(value) {
            self.tintColor = value ? Theme.activeButtonColor : Theme.inactiveButtonColor
        }
    }
    
    // MARK: - Private
    
    private func setupButton() {
        bubbleLayer = CAShapeLayer()
        bubbleLayer.fillColor = Theme.mainColor.withAlphaComponent(0.5).cgColor
        bubbleLayer.opacity = 0.0
        self.layer.insertSublayer(bubbleLayer, at: 0)
        self.updateBubbleLayerFrame()
        self.clipsToBounds = true
    }
    
    private func updateBubbleLayerFrame() {
        bubbleLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.width)
        bubbleLayer.position = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        bubbleLayer.path = UIBezierPath(ovalIn: bubbleLayer.bounds).cgPath
    }
    
    private func playTouchAnimation() {
        self.bubbleLayer.removeAllAnimations()
        let sAnimation = CABasicAnimation(keyPath: "transform.scale")
        sAnimation.fromValue = 0.05
        sAnimation.toValue = 1.0
        sAnimation.duration = 0.3
        sAnimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
        bubbleLayer.opacity = 1.0
        self.bubbleLayer.add(sAnimation, forKey: "scale")
    }
    
    private func playReleaseAnimation() {
        let oAnimation = CABasicAnimation(keyPath: "opacity")
        oAnimation.fromValue = 1.0
        oAnimation.toValue = 0.0
        oAnimation.duration = 0.3
        bubbleLayer.opacity = 0.0
        self.bubbleLayer.add(oAnimation, forKey: "opacity")
    }
}
