//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

typealias ImageSelectedHandler = (UIImage?) -> ()

class ImagePickerManager: NSObject {
    
    private static var pickerInstance = ImagePickerManager()
    
    private weak var parentController: UIViewController!
    private var onImagePicked: ImageSelectedHandler?
    private var originalStatusBarStyle: UIStatusBarStyle?
    
    class func openPicker(from controller: UIViewController, onImagePicked: @escaping ImageSelectedHandler) {
        pickerInstance.parentController = controller
        pickerInstance.onImagePicked = onImagePicked
        pickerInstance.showImageSourceDialog()
    }
    
    private func showImageSourceDialog() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.onImagePicked = nil
        }
        let libraryAction = UIAlertAction(title: "Load from library", style: .default) { _ in
            let ipVC = UIImagePickerController()
            ipVC.allowsEditing = true
            ipVC.sourceType = .photoLibrary
            ipVC.delegate = self
            self.parentController.present(ipVC, animated: true, completion: nil)
            self.originalStatusBarStyle = UIApplication.shared.statusBarStyle
        }
        let cameraAction = UIAlertAction(title: "Take photo", style: .default) { _ in
            let ipVC = UIImagePickerController()
            ipVC.allowsEditing = true
            ipVC.sourceType = .camera
            ipVC.delegate = self
            self.parentController.present(ipVC, animated: true, completion: nil)
            self.originalStatusBarStyle = UIApplication.shared.statusBarStyle
        }
        alertController.addAction(cancelAction)
        alertController.addAction(libraryAction)
        alertController.addAction(cameraAction)
        self.parentController.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func restoreStatusBarStyle() {
        guard let originalStyle = self.originalStatusBarStyle else { return }
        UIApplication.shared.statusBarStyle = originalStyle
        self.originalStatusBarStyle = nil
    }
}

extension ImagePickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController,
                                     didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        picker.dismiss(animated: true, completion: {
            self.onImagePicked?(image)
            self.onImagePicked = nil
            self.restoreStatusBarStyle()
        })
    }
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: {
            self.onImagePicked = nil
            self.restoreStatusBarStyle()
        })
    }
}
