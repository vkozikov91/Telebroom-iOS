//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit
import Kingfisher

class ImageViewerViewController: UIViewController {
    
    var url: URL!
    
    @IBOutlet private weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.setImageAnimated(from: url, placeholder: #imageLiteral(resourceName: "img_placeholder"))
    }
    
    @IBAction func onTapGesture(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
}
