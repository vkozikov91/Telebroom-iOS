//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

class ImageViewer {
    class func showImage(url: URL?, from presenter: UIViewController) {
        guard url != nil else { return }
        let sb = UIStoryboard(name: "ImageViewer", bundle: nil)
        let ivVC = sb.instantiateInitialViewController() as! ImageViewerViewController
        ivVC.url = url
        ivVC.modalTransitionStyle = .crossDissolve
        ivVC.modalPresentationStyle = .overFullScreen
        DispatchQueue.main.async {
            presenter.present(ivVC, animated: true, completion: nil)
        }
    }
}
