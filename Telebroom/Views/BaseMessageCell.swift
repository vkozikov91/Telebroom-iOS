//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

class BaseMessageCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Bottom-To-Top Table View trick
        self.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.layer.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1)
    }
    
    open func setMessage(_ message: Message) { }
    open func setSenderImage(url: URL?) { }
    open func clearSenderImage() { }
    
}
