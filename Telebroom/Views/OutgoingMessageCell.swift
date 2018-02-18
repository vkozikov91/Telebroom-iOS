//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

class OutgoingMessageCell: BaseMessageCell {
    
    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var bubbleView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageTextLabel.font = Theme.mainFont(16)
        messageTextLabel.textColor = Theme.outgoingMessageTextColor
        bubbleView.backgroundColor = Theme.outgoingMessageBackgroundColor
        bubbleView.layer.cornerRadius = 15.0
        bubbleView.layer.masksToBounds = true
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.clear
        self.selectedBackgroundView = selectedBackgroundView
    }
    
    override func setMessage(_ message: Message) {
        messageTextLabel.text = message.text
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) { }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: false)
        self.bubbleView.backgroundColor = Theme.outgoingMessageBackgroundColor
    }
    
}
