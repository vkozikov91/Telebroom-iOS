//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

class IncomingMessageCell: BaseMessageCell {
    
    @IBOutlet private weak var contactImageView: ProfileImageView!
    @IBOutlet private weak var messageTextLabel: UILabel!
    @IBOutlet private weak var bubbleView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageTextLabel.font = Theme.mainFont(16)
        messageTextLabel.textColor = Theme.incomingMessageTextColor
        bubbleView.backgroundColor = Theme.incomingMessageBackgroundColor
        bubbleView.layer.cornerRadius = 15.0
        bubbleView.layer.masksToBounds = true
    }
    
    override func setMessage(_ message: Message) {
        messageTextLabel.text = message.text
    }
    
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
