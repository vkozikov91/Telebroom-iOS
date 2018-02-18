//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit
import PromiseKit
import RxSwift

class BaseViewController: UIViewController, Routable {
    
    var router: AppRouter!
    var rxDisposeBag = DisposeBag()
    
    @IBOutlet weak var keyboardDependableConstraint: NSLayoutConstraint?
    var keyboardConstraintInset: CGFloat = 0.0
    var onKeyboardWillAppear: VoidClosure?
    var onKeyboardDidAppear: VoidClosure?
    var onKeyboardWillHide: VoidClosure?
    var onKeyboardDidHide: VoidClosure?
    
    private var pendingAppearError: ApiError? // Error that was caught between 'viewDidLoad' and 'viewDidAppear'
    private var isControllerReady = false
    
    var mainNavigationController: MainNavigationController {
        guard let tabBarVC = self.tabBarController,
            let navVC = tabBarVC.navigationController,
            let mainNavVC = navVC as? MainNavigationController
            else { return self.navigationController as! MainNavigationController }
        return mainNavVC
    }
        
    var viewModels = [BaseViewModel]() {
        didSet { self.bindViewModels() }
    }
    
    
    // MARK: - Overriding
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.decorateViewController()
        self.setViewModels()
        print("+ \(String(describing: type(of: self))) init")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addKeyboardObserver()
        isControllerReady = true
        showPendingErrorIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeKeyboardObserver()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController {
            var destinationVC = navigationController.topViewController! as! Routable
            destinationVC.router = self.router
        } else {
            var destinationVC = segue.destination as! Routable
            destinationVC.router = self.router
        }
    }
    
    deinit {
        print("- \(String(describing: type(of: self))) dealloc")
    }
    
    
    // MARK: -
    
    open func decorateViewController() {
        self.view.backgroundColor = Theme.mainBackgroundColor
    }
    
    open func setViewModels() { }
    open func bindViewModels() { }

    func runSegue(_ id: String) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: id, sender: nil)
        }
    }
    
    
    // MARK: - Error Handling

    func handleError(_ error: Error, completion: VoidClosure?) {
        /*
         *'Error' parameter type instead of 'ApiError' is needed, since the method is used in
         * 'catch' block for Promises
         */
        let apiError = error as! ApiError
        if isControllerReady {
            showError(apiError, completionHandler: completion)
        } else {
            self.pendingAppearError = apiError
        }
    }
    
    private func showPendingErrorIfNeeded() {
        guard let error = self.pendingAppearError else { return }
        showError(error)
        self.pendingAppearError = nil
    }
    
    private func showError(_ error: ApiError, completionHandler: VoidClosure? = nil) {
        let alertController = UIAlertController(title: "Oops!",
                                                message: error.localizedDescription,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK",
                                     style: .default,
                                     handler: { _ in completionHandler?() })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Keyboard Appearance Handling

extension BaseViewController {
    
    private func addKeyboardObserver() {
        guard keyboardDependableConstraint != nil else { return }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleKeyboardAppearanceNotifification(_:)),
            name: .UIKeyboardWillShow,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleKeyboardAppearanceNotifification(_:)),
            name: .UIKeyboardWillHide,
            object: nil)
    }
    
    private func removeKeyboardObserver() {
        guard keyboardDependableConstraint != nil else { return }
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func handleKeyboardAppearanceNotifification(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue,
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double
            else { return }
        var keyboardHeight = endFrameValue.cgRectValue.height
        keyboardHeight += self.keyboardConstraintInset
        if #available(iOS 11.0, *) {
            keyboardHeight -= view.safeAreaInsets.bottom
        }
        let willShow = (notification.name == .UIKeyboardWillShow)
        willShow ? self.onKeyboardWillAppear?() : self.onKeyboardWillHide?()
        keyboardDependableConstraint?.constant = willShow ? keyboardHeight : 0.0
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (finished) in
            willShow ? self.onKeyboardDidAppear?() : self.onKeyboardDidHide?()
        })
    }
}
