//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

class Theme {
    
    // MARK: - Fonts
    
    class func mainFont(_ size: CGFloat, bold: Bool = false) -> UIFont {
        let fontName = bold ? "EuphemiaUCAS-Bold" : "EuphemiaUCAS"
        return UIFont(name: fontName, size: size)!
    }
    
    // MARK: - Colors
    
    class var mainBackgroundGradient: (UIColor, UIColor) {
        return (UIColor.withRGB(5, 150, 213), UIColor.withRGB(115, 71, 208))
    }
    
    class var mainColor: UIColor {
        return UIColor.withRGB(0, 128, 255)//UIColor.withRGB(63, 203, 255)
    }
    
    class var mainBackgroundColor: UIColor {
        return UIColor.white
    }
    
    class var statusOfflineColor: UIColor {
        return UIColor.withRGB(128, 0, 64)
    }
    
    class var statusOnlineColor: UIColor {
        return UIColor.withRGB(0, 128, 128)
    }
    
    // MARK: - UI Elements
    
    class var tabBarBorderColor: UIColor {
        return UIColor.withRGB(222, 226, 234)
    }
    
    class var activeButtonColor: UIColor {
        return mainColor
    }
    
    class var inactiveButtonColor: UIColor {
        return UIColor.lightGray
    }
    
    class var incomingMessageBackgroundColor: UIColor {
        return UIColor.withRGB(237, 237, 237)
    }
    
    class var incomingMessageTextColor: UIColor {
        return UIColor.withRGB(77, 69, 71)
    }
    
    class var outgoingMessageBackgroundColor: UIColor {
        return mainColor
    }
    
    class var outgoingMessageTextColor: UIColor {
        return UIColor.white
    }
    
    class var selectedCellBackgroundColor: UIColor {
        return UIColor.black.withAlphaComponent(0.3)
    }
    
    class var darkTextColor: UIColor {
        return UIColor.withRGB(230, 230, 230)
    }
    
    class var lightTextColor: UIColor {
        return UIColor.white
    }

}
