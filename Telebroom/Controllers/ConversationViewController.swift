//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit
import SnapKit
import PromiseKit

class ConversationViewController: BaseTableViewController {
    
    @IBOutlet private weak var conversationContainerView: UIView!
    
    @IBOutlet private weak var contactTitleLabel: UILabel!
    @IBOutlet private weak var contactPresenceLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var sendButton: UIButton!
    
    @IBOutlet private weak var editingBarView: UIView!
    @IBOutlet private weak var noMessagesLabel: UILabel!
    @IBOutlet private weak var editButton: UIButton!
    
    private let kConversationTopBarHeight: CGFloat = 60.0
    private let kConversationBottomBarHeight: CGFloat = 50.0
    
    private var messages: [Message] { return messagingViewModel.messages.value }
    
    private var messagingViewModel: MessagingViewModelProtocol {
        return self.viewModels.first! as! MessagingViewModelProtocol
    }
    
    private var contactsViewModel: ContactsViewModelProtocol {
        return self.viewModels.last! as! ContactsViewModelProtocol
    }

    // MARK: -

    var remoteUser: RemoteUserViewModel!
    
    private let transitioningController = ConversationTransitioningController()
    override var transitioningDelegate: UIViewControllerTransitioningDelegate? {
        get { return self.transitioningController }
        set { }
    }
    
    // MARK: - Override
    
    override func setViewModels() {
        let messagingViewModel = self.router.vmFactory.getMessagingViewModel()
        messagingViewModel.remoteUser = self.remoteUser
        self.viewModels = [messagingViewModel, router.vmFactory.getContactsViewModel()]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadMessages()
    }
    
    override func bindTableView() {
        let ibTableView = self.conversationContainerView.subviews.first(where: { $0 is UITableView })
        self.tableView = ibTableView as! UITableView
    }
    
    override func configureTableView() {
        super.configureTableView()
        let proxy = TableViewProxy(for: self.tableView)
        proxy.reuseIdentifierBinder = { item in
            let message = item as! Message
            switch message.type! {
            case .image:
                return message.isIncoming ? IncomingImageCell.reuseId : OutgoingImageCell.reuseId
            case .deleted:
                return DeletedMessageCell.reuseId
            case .text:
                return message.isIncoming ? IncomingMessageCell.reuseId : OutgoingMessageCell.reuseId
            }
        }
        proxy.itemBinder = { [unowned self] (item, cell) in
            guard let message = item as? Message, let cell = cell as? BaseMessageCell
                else { return }
            cell.setMessage(message)
            if message.isIncoming {
                if self.isHeaderMessage(message) {
                    cell.setSenderImage(url: self.remoteUser.fullImageUrl)
                } else {
                    cell.clearSenderImage()
                }
            }
        }
        proxy.tapHandler = { [unowned self] item in
            guard !self.tableView.isEditing, let message = item as? Message, message.type == .image
                else { return }
            ImageViewer.showImage(url: message.imageUrl, from: self)
        }
        proxy.onMoreContentRequestedHandler = { [unowned self] in
            self.messagingViewModel.loadMoreMessages()
                .catch { self.handleError($0, completion: nil) }
        }
        proxy.canEditItemBinder = { item -> Bool in
            guard let message = item as? Message else { return false }
            return !message.isIncoming && message.type != .deleted
        }
        self.tableViewProxy = proxy
        
        // Bottom-To-Top Table View trick
        self.tableView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.tableView.layer.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1)
    }
    
    override func decorateViewController() {
        super.decorateViewController()
        self.conversationContainerView.layer.cornerRadius = 10.0
        self.conversationContainerView.layer.masksToBounds = true
        self.onKeyboardDidAppear = { [weak self] in self?.scrollToLastMessage(animated: true) }
        let bOffset: CGFloat = kConversationBottomBarHeight + 20.0 // some space between text and bottom bar
        self.tableView.contentInset = UIEdgeInsets(top: kConversationTopBarHeight, left: 0, bottom: bOffset, right: 0)
        self.textField.font = Theme.mainFont(14)
        self.keyboardConstraintInset = 5.0
    }
    
    deinit {
        self.messagingViewModel.clear()
    }
    
    // MARK: - Private
    
    override func bindViewModels() {
        super.bindViewModels()

        // Messaging VM
        self.messagingViewModel.messages
            .asObservable()
            .scan( [ [] , [] ] ) { return [ $0[1], $1 ] }   // Logic to bring
            .map { array in (array[0], array[1]) }          // old and new values
            .subscribe(onNext: { [weak self] (oldValue, newValue) in
                self?.updateTableViewItems(oldMessages: oldValue, newMessages: newValue)
                self?.noMessagesLabel.isHidden = (newValue.count > 0)
            })
            .disposed(by: self.rxDisposeBag)
        self.messagingViewModel.noMoreMessagesToFetch
            .asObservable()
            .subscribe(onNext: { [unowned self] noMoreMessages in
                self.tableViewProxy.showsLoadingCell = self.messages.count > 0 && !noMoreMessages
            })
            .disposed(by: self.rxDisposeBag)
    
        // Remote User VM
        self.contactTitleLabel.text = remoteUser.fullName
        self.remoteUser.isOnline
            .asObservable()
            .subscribe(onNext: { [weak self] _ in self?.animateStatusChange() })
            .disposed(by: self.rxDisposeBag)
    }
    
    private func showEditingBar() {
        self.editingBarView.alpha = 0.0
        self.editingBarView.isHidden = false
        UIView.animate(withDuration: 0.2) { self.editingBarView.alpha = 1.0 }
    }
    
    private func hideEditingBar() {
        UIView.animate(withDuration: 0.2,
                       animations: { self.editingBarView.alpha = 0.0 },
                       completion: { _ in self.editingBarView.isHidden = true })
    }
    
    private func animateStatusChange() {
        let newStatusString = self.remoteUser.isOnline.value ? "online" : "offline"
        guard self.contactPresenceLabel.text != newStatusString else { return }
        let transition = CATransition()
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        self.contactPresenceLabel.text = newStatusString
        self.contactPresenceLabel.textColor = self.remoteUser.isOnline.value ?
            Theme.statusOnlineColor : Theme.statusOfflineColor
        self.contactPresenceLabel.layer.add(transition, forKey: "statusTransition")
    }
    
    private func closeConversation() {
        self.messagingViewModel.remoteUser?.hasUnreadMessages.value = false
        runSegue(Constants.segueIDs.unwindConversationToContacts)
    }
    
    private func showEditMenu() {
        guard !self.tableView.isEditing else {
            self.tableView.setEditing(false, animated: true)
            return
        }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if self.messages.count > 0 {
            alertController.addAction(UIAlertAction(title: "Delete messages", style: .default) { _ in
                self.textField.resignFirstResponder()
                self.tableView.setEditing(true, animated: true)
                self.showEditingBar()
            })
        }
        alertController.addAction(UIAlertAction(title: "Remove from contacts", style: .destructive) { _ in
            self.contactsViewModel.removeFromContacts(self.remoteUser).catch { error in  }
            self.closeConversation()
        })
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Messages handling
    
    private func updateTableViewItems(oldMessages: [Message], newMessages: [Message]) {
        let oldCount = oldMessages.count
        let newCount = newMessages.count
        if (oldCount == 0 && newCount != 0) {
            self.tableViewProxy.setItems(newMessages)
        } else if (newCount - oldCount == 1
            && newCount > 1
            && newMessages[1].id == oldMessages.first!.id) {
            // Received one new message
            self.tableViewProxy.insertItem(newMessages.first!,
                                           with: self.rowInsertAnimation(for: newMessages.first!))
        } else if newCount > oldCount && newMessages.first!.id == oldMessages.first?.id {
            // Loaded portion of messages
            let itemsToAdd = Array(newMessages[oldCount..<newCount])
            self.tableViewProxy.appendItems(itemsToAdd)
        } else {
            self.tableViewProxy.setItems(newMessages)
        }
    }
    
    private func loadMessages() {
        showActivityIndicator()
        self.messagingViewModel.loadLatestMessages()
            .catch { self.handleError($0, completion: nil) }
            .always { self.hideActivityIndicator() }
    }
    
    private func sendMessage(_ text: String?) {
        guard let text = text, text.count > 0, text != "", !text.contains(Message.serviceSymbols)
            else { return }
        self.textField.text = ""
        scrollToLastMessage(animated: false)
        self.messagingViewModel.sendMessage(text)
            .catch { self.handleError($0, completion: nil) }
    }
    
    private func sendImage(_ image: UIImage) {
        showActivityIndicator()
        self.messagingViewModel.sendImage(image)
            .then { self.scrollToLastMessage(animated: false) }
            .catch { self.handleError($0, completion: nil) }
            .always { self.hideActivityIndicator() }
    }
    
    private func deleteSelectedMessages() {
        guard self.tableView.isEditing,
            let indexesToDelete = self.tableView.indexPathsForSelectedRows,
            indexesToDelete.count > 0
            else { return }
        showActivityIndicator()
        let rowsToDelete = indexesToDelete.map{ $0.row }
        let messagesToDelete = self.messages.enumerated().filter { rowsToDelete.contains($0.offset) }
        let idsToDelete = messagesToDelete.map { ($0.element).id! }
        self.messagingViewModel.deleteMessages(ids: idsToDelete)
            .catch { self.handleError($0, completion: nil) }
            .always {
                self.tableView.setEditing(false, animated: true)
                self.hideEditingBar()
                self.hideActivityIndicator()
            }
    }
    
    private func isHeaderMessage(_ message: Message) -> Bool {
        guard let index = self.messages.index(where: { $0.id == message.id }), index != (messages.count - 1)
            else { return true }
        let previousMessage = self.messages[index + 1]
        return previousMessage.type == .image || (message.isIncoming != previousMessage.isIncoming)
    }
    
    private func rowInsertAnimation(for message: Message) -> UITableViewRowAnimation {
        if message.type! == .deleted {
            return UITableViewRowAnimation.fade
        }
        return message.isIncoming ? UITableViewRowAnimation.right :
            UITableViewRowAnimation.left
    }
    
    private func scrollToLastMessage(animated: Bool) {
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
    }
}

// MARK: - IBActions

extension ConversationViewController {
    
    @IBAction private func onEditButtonPressed(_ sender: UIButton) {
        self.textField.resignFirstResponder()
        showEditMenu()
    }
    
    @IBAction private func onDeleteButtonPressed(_ sender: UIButton) {
        deleteSelectedMessages()
    }
    
    @IBAction private func onCancelButtonPressed(_ sender: UIButton) {
        self.tableView.setEditing(false, animated: true)
        hideEditingBar()
    }
    
    @IBAction private func onAttachImageButtonPressed(_ sender: UIButton) {
        ImagePickerManager.openPicker(from: self) { image in
            guard let image = image else { return }
            self.sendImage(image)
        }
    }
    
    @IBAction private func onSendButtonPressed(_ sender: UIButton) {
        sendMessage(textField.text)
    }
    
    @IBAction private func onSwipeCloseGesture(_ recognizer: UISwipeGestureRecognizer) {
        closeConversation()
    }
}

// MARK: - Text Field Delegate

extension ConversationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage(textField.text)
        return true
    }
    
    @IBAction func textFieldTextDidChange(_ sender: UITextField) { }
}
