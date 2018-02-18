//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

class ProfileImageView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.applyCircleMask()
    }
    
    private func applyCircleMask() {
        self.clipsToBounds = true
        self.layer.cornerRadius = self.bounds.height / 2
        self.layer.borderColor = UIColor.withRGB(237, 237, 237).cgColor
        self.layer.borderWidth = 1.0// * UIScreen.main.scale
    }
}
