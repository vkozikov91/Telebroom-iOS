//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

class AppBootstrapper {
    
    class func getInitialViewController() -> BaseViewController {
        let startSB = UIStoryboard(name: "Login", bundle: nil)
        let mainNavVC = (startSB.instantiateInitialViewController() as! MainNavigationController)
        let introVC = mainNavVC.topViewController as! IntroViewController
        let router = AppRouter()
        router.mainNavigationController = mainNavVC
        introVC.router = router
        return introVC
    }
    
    class func start() {
        
    }
    
}
