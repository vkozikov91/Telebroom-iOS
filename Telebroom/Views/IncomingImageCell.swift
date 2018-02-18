//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import Foundation

class IncomingImageCell: BaseImageMessageCell {
    
    @IBOutlet private weak var contactImageView: ProfileImageView!
    
    override func setSenderImage(url: URL?) {
        self.contactImageView.isHidden = false
        if url == nil {
            self.contactImageView.image = #imageLiteral(resourceName: "img_user")
        } else {
            self.contactImageView.setImageAnimated(from: url, placeholder: #imageLiteral(resourceName: "img_user"))
        }
    }
    
    override func clearSenderImage() {
        self.contactImageView.image = nil
        self.contactImageView.isHidden = true
    }
}
