//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit
import PromiseKit

class SearchResultViewController: BaseViewController {
    
    var remoteUser: RemoteUserViewModel!
    
    var contactsViewModel: ContactsViewModelProtocol {
        return self.viewModels.first! as! ContactsViewModelProtocol
    }
    
    private var shouldRemoveContact = false

    @IBOutlet weak private var actionButton: BorderedButton!
    @IBOutlet weak private var userImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var detailsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateActionButtonState()
    }
    
    override func setViewModels() {
        self.viewModels = [router.vmFactory.getContactsViewModel()]
    }
    
    override func bindViewModels() {
        let contactsVM = self.viewModels.first as! ContactsViewModel
        contactsVM.contacts
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.updateActionButtonState()
            })
            .disposed(by: self.rxDisposeBag)
    }
    
    override func decorateViewController() {
        self.userImageView.setImageAnimated(from: remoteUser.fullImageUrl, placeholder: #imageLiteral(resourceName: "img_user"))
        self.titleLabel.text = self.remoteUser.fullName
        self.detailsLabel.text = self.remoteUser.username
    }
    
    private func updateActionButtonState() {
        self.actionButton.isActivityIndicatorVisible = false
        self.shouldRemoveContact = contactsViewModel.contacts.value.map { $0.username }.contains(self.remoteUser.username)
        self.actionButton.text = self.shouldRemoveContact ? "Remove From Contacts" : "Add To Contacts"
    }
}

extension SearchResultViewController {
    
    @IBAction private func onBackPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onActionButtonPressed(_ sender: BorderedButton) {
        // A copy is used here because if this object is written and then removed from Realm,
        // it will be invalidated even if there are active references to it
        let userCopy = RemoteUserViewModel(value: remoteUser)
        actionButton.isActivityIndicatorVisible = true
        if shouldRemoveContact {
            contactsViewModel.removeFromContacts(userCopy)
                .catch { self.handleError($0, completion: nil) }
                .always { self.updateActionButtonState() }
        } else {
            userCopy.verified = true
            contactsViewModel.addToContacts(userCopy)
                .catch { self.handleError($0, completion: nil) }
                .always { self.updateActionButtonState() }
        }
    }
}
