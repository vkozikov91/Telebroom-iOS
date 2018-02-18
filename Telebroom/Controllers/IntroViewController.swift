//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit
import PromiseKit

class IntroViewController: BaseViewController {
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    var profileService: ProfileService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureServices()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tryLogin()
    }
    
    override func decorateViewController() {
        self.view.backgroundColor = Theme.mainColor
    }
    
    
    // MARK: Private
    
    private func configureServices() {
        self.profileService = router.serviceFactory.getProfileService()
    }
    
    private func tryLogin() {
        guard self.profileService.canAutoLogin else {
            goToLogin()
            return
        }
        self.activityIndicator.startAnimating()
        self.profileService.tryAutoLogin()
            .then { self.goToMain() }
            .catch { error in
                self.handleError(error, completion: { [weak self] in
                    self?.goToLogin()
                })
            }
            .always { self.activityIndicator.stopAnimating() }
    }
    
    private func goToMain() {
        runSegue(Constants.segueIDs.introToMain)
    }
    
    private func goToLogin() {
        runSegue(Constants.segueIDs.introToLogin)
    }
}
