//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

class DeletedMessageCell: BaseMessageCell {
    
    @IBOutlet weak var messageTextLabel: UILabel!
    
    open override func setMessage(_ message: Message) {
        self.messageTextLabel.font = Theme.mainFont(12)
        self.messageTextLabel.text = "♻︎ DELETED MESSAGE"
    }

}
