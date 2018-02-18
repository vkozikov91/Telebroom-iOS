//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit
import Kingfisher
import PromiseKit

typealias VoidClosure = () -> Void

extension Array where Element: Equatable {
    
    mutating func remove(_ element: Element) {
        guard let index = self.index(of: element) else { return }
        _ = self.remove(at: index)
    }
    
    func compare(with array: [Element]) -> (added: [Element], removed: [Element]) { // Not Used
        var elementsAdded = [Element]()
        var elementsRemoved = [Element]()
        self.forEach { (element) in
            if !array.contains(element) {
                elementsRemoved.append(element)
            }
        }
        array.forEach { (element) in
            if !self.contains(element) {
                elementsAdded.append(element)
            }
        }
        return (elementsAdded, elementsRemoved)
    }
}

extension DateFormatter {
    class func initWithMongoFormat() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }
}

extension NSError {
    static var defaultError: NSError {
        return NSError(domain: "", code: 0, userInfo: nil)
    }
}

extension UIImageView {
    func setImageAnimated(_ image: UIImage?) {
        DispatchQueue.main.async {
            UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.image = image
            }, completion: nil)
        }
    }
    func setImageAnimated(from url: URL?, placeholder: UIImage? = nil) {
        if let url = url {
            self.kf.setImage(with: url,
                             placeholder: placeholder,
                             options: [.transition(.fade(0.3))],
                             progressBlock: nil,
                             completionHandler: nil)
        } else {
            self.setImageAnimated(placeholder)
        }
    }
}

extension String {
    func toUTF8() -> Data {
        return self.data(using: .utf8)!
    }
    func toBool() -> Bool {
        let nsString = self as NSString
        return nsString.boolValue
    }
}

extension UIColor {
    class func withRGB(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor {
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1.0)
    }
}

extension UIImage {
    class func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return img
    }
}

extension UITableViewCell {
    class var reuseId: String {
        return String(describing: self)
    }
}

extension Promise {
    static var void: Promise<Void> {
        return Promise<Void>(value: ())
    }
}
