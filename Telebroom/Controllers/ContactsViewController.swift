//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit
import PromiseKit
import RxSwift
import RxCocoa

class ContactsViewController: BaseTableViewController {
    
    @IBOutlet private weak var noContactsLabel: UILabel!
    
    private var contactsViewModel: ContactsViewModelProtocol {
        return self.viewModels.first! as! ContactsViewModelProtocol
    }

    private var selectedContact: RemoteUserViewModel?
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadContacts()
    }
    
    override func configureTableView () {
        super.configureTableView()
        self.tableView.rowHeight = 70.0
    }
    
    override func setViewModels() {
        self.viewModels = [self.router.vmFactory.getContactsViewModel()]
    }
    
    override func bindViewModels() {
        self.contactsViewModel.contacts
            .asObservable()
            .map({ contacts -> [RemoteUserViewModel] in
                return contacts.sorted { (a, b) -> Bool in
                    if a.verified && !b.verified {
                        return true
                    } else if !a.verified && b.verified {
                        return false
                    } else {
                        return a.fullName < b.fullName
                    }
                }
            })
            .bind(to: self.tableView.rx.items(
                cellIdentifier: MainUserCell.reuseId,
                cellType: MainUserCell.self)) { row, remoteUserVM, cell in
                    cell.viewModel = remoteUserVM
                }
            .disposed(by: self.rxDisposeBag)
        self.contactsViewModel.contacts
            .asObservable()
            .bind { [weak self] in self?.noContactsLabel.isHidden = !$0.isEmpty }
            .disposed(by: self.rxDisposeBag)
        self.tableView.rx
            .modelSelected(RemoteUserViewModel.self)
            .subscribe(onNext: { [weak self] remoteUser in
                self?.selectedContact = remoteUser
                if remoteUser.verified {
                    self?.runSegue(Constants.segueIDs.mainToConversation)
                } else {
                    self?.promptVerifyContact()
                }
            })
            .disposed(by: self.rxDisposeBag)
        self.contactsViewModel.hasUnreadMessages
            .asObservable()
            .bind { [weak self] hasUnread in
                let tabBarVC = self?.tabBarController as? BaseTabBarController
                let tabBar = tabBarVC?.tabBar as? TelebroomTabBar
                tabBar?.showsUnreadMessages = hasUnread
            }
            .disposed(by: self.rxDisposeBag)
    }
    
    deinit {
        self.contactsViewModel.clear()
    }
    
    // MARK: - Private
    
    private func loadContacts() {
        showActivityIndicator()
        self.contactsViewModel.getContacts()
            .then { self.openPendingConversationIfNeeded() }
            .catch {
                self.clearPendingConversation()
                self.handleError($0, completion: { [weak self] in
                    self?.loadContacts()
                })
            }
            .always { self.hideActivityIndicator() }
    }
    
    private func promptVerifyContact() {
        let title = "Add '\( selectedContact!.fullName)' to contacts?"
        let alertController = UIAlertController(title: title, message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.contactsViewModel.verifyContact(self.selectedContact!)
                .always { self.selectedContact = nil }
        })
        let noAction = UIAlertAction(title: "Cancel", style: .default, handler: { _ in
            self.selectedContact = nil
        })
        alertController.addAction(okAction)
        alertController.addAction(noAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func clearPendingConversation() {
        self.router.appBus.pendingConversationUsername = nil
    }
    
    // MARK: - NAVIGATION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == Constants.segueIDs.mainToConversation {
            let cVC = segue.destination as! ConversationViewController
            cVC.remoteUser = self.selectedContact
            self.selectedContact!.hasUnreadMessages.value = false
            self.contactsViewModel.updateHasUnreadMessages()
            self.clearPendingConversation()
        }
    }
    
    func openPendingConversationIfNeeded() {
        guard let username = self.router.appBus.pendingConversationUsername,
            username != self.selectedContact?.username,
            let contact = self.contactsViewModel.contacts.value.first(where: { $0.username == username })
            else { return }
        self.selectedContact = contact
        if self.presentedViewController != nil {
            self.presentedViewController?.dismiss(animated: true, completion: {
                self.runSegue(Constants.segueIDs.mainToConversation)
            })
        } else {
            runSegue(Constants.segueIDs.mainToConversation)
        }
    }
    
    @IBAction func onUnwindToContacts(segue: UIStoryboardSegue) {
        self.contactsViewModel.updateHasUnreadMessages()
        self.selectedContact = nil
    }
    
}
