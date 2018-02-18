//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit
import PromiseKit

class LoginViewController: BaseViewController {
    
    @IBOutlet private weak var titleImageView: UIImageView!
    @IBOutlet private var titleLabelCenteredConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var firstnameTextField: UITextField!
    @IBOutlet private weak var secondnameTextField: UITextField!
    
    @IBOutlet private weak var primaryButton: BorderedButton!
    @IBOutlet private weak var secondaryButton: BorderedButton!
    
    @IBOutlet private var signupContainerHiddenConstraint: NSLayoutConstraint!
    
    
    // MARK: -
    
    private var profileService: ProfileService!
    
    private var signUpMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureServices()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearFields(keepUsername: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.playAppearAnimationIfNeeded()
    }
    
    override func decorateViewController() {
        super.decorateViewController()
        [usernameTextField, passwordTextField, firstnameTextField, secondnameTextField].forEach {
            ($0 as! UnderlinedTextField).lineColor = UIColor.white
        }
        self.onKeyboardWillAppear = { [weak self] in
            UIView.animate(withDuration: 0.3, animations: {
                self?.titleImageView.alpha = 0.0
            })
        }
        self.onKeyboardWillHide = { [weak self] in
            UIView.animate(withDuration: 0.3, animations: {
                self?.titleImageView.alpha = 1.0
            })
        }
        decorateView(forLogin: true, animated: false)
    }
    
    
    // MARK: - Private
    
    private func configureServices() {
        self.profileService = self.router.serviceFactory.getProfileService()
    }
    
    private func playAppearAnimationIfNeeded() {
        guard self.titleLabelCenteredConstraint.isActive else { return }
        self.titleLabelCenteredConstraint.isActive = false
        UIView.animate(withDuration: 1.0,
                       animations: { self.view.layoutIfNeeded() })
    }
    
    private func login() {
        guard areCredentialsValid() else { return }
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        dismissKeyboard()
        showActivityIndicator()
        self.profileService.login(username: username, password: password)
            .then { self.goToMain() }
            .catch { self.handleError($0, completion: nil) }
            .always { self.hideActivityIndicator() }
    }
    
    private func signup() {
        guard areCredentialsValid() else { return }
        let uName = usernameTextField.text!
        let pass = passwordTextField.text!
        let fName = firstnameTextField.text
        let sName = secondnameTextField.text
        dismissKeyboard()
        showActivityIndicator()
        self.profileService.signup(username: uName, password: pass, firstName: fName, secondName: sName)
            .then { self.goToMain() }
            .catch { self.handleError($0, completion: nil) }
            .always { self.hideActivityIndicator() }
    }
    
    private func areCredentialsValid() -> Bool {
        return (usernameTextField.text!.count >= 3
            && passwordTextField.text!.count >= 3)
    }
    
    private func decorateView(forLogin: Bool, animated: Bool) {
        dismissKeyboard()
        self.signUpMode = !forLogin
        self.signupContainerHiddenConstraint.isActive = forLogin
        if animated {
            UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
        } else {
            UIView.performWithoutAnimation { self.view.layoutIfNeeded() }
        }
        self.primaryButton.setTitle((forLogin ? "LOG IN" : "SIGN UP"), for: .normal)
        self.secondaryButton.setTitle((forLogin ? "Don't have an account?": "Cancel"), for: .normal)
        self.passwordTextField.returnKeyType = forLogin ? .go : .next
    }
    
    private func dismissKeyboard() {
        [usernameTextField, passwordTextField, firstnameTextField, secondnameTextField].forEach {
            guard $0!.isFirstResponder else { return }
            $0!.resignFirstResponder()
        }
    }
    
    private func clearFields(keepUsername: Bool) {
        if !keepUsername {
            self.usernameTextField.text = ""
        }
        [passwordTextField, firstnameTextField, secondnameTextField].forEach { $0!.text = "" }
    }

    private func goToMain() {
        runSegue(Constants.segueIDs.loginToMain)
    }

}


extension LoginViewController {
    
    @IBAction func onPrimaryButtonPressed(_ sender: UIButton) {
        self.signUpMode ? signup() : login()
    }
    
    @IBAction func onSecondaryButtonPressed(_ sender: UIButton) {
        decorateView(forLogin: self.signUpMode, animated: true)
    }
}


extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.usernameTextField {
            self.passwordTextField.becomeFirstResponder()
        } else if textField == self.passwordTextField {
            if self.signUpMode {
               self.firstnameTextField.becomeFirstResponder()
            } else {
               login()
            }
        } else if textField == self.firstnameTextField {
            self.secondnameTextField.becomeFirstResponder()
        } else if textField == self.secondnameTextField {
            signup()
        }
        return false
    }
}
