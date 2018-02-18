//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

class PopUpView: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func appear() {
        self.isHidden = false
        self.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        UIView.animate(withDuration: 0.7,
                       delay: 0.0,
                       usingSpringWithDamping: 0.3,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear,
                       animations: { self.transform = CGAffineTransform.identity },
                       completion: nil)
    }
    
    func disappear() {
        self.isHidden = true
    }
    
    private func setup() {
        self.layer.cornerRadius = self.bounds.height / 2
        self.clipsToBounds = true
        self.isUserInteractionEnabled = false
    }
}
