//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit
import Kingfisher

class BaseImageMessageCell: BaseMessageCell {
    
    @IBOutlet weak var messageImageView: UIImageView!
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) { }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.messageImageView.clipsToBounds = true
        self.messageImageView.layer.cornerRadius = 10.0
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.clear
        self.selectedBackgroundView = selectedBackgroundView
    }
    
    override func setMessage(_ message: Message) {
        guard let imageUrl = message.imageUrl else { return }
        self.messageImageView.kf.setImage(with: imageUrl,
                                          placeholder: #imageLiteral(resourceName: "img_placeholder"),
                                          options: [.transition(.fade(0.3))])
    }
}
