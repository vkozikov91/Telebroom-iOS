//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit
import PromiseKit
import RxSwift

protocol ContactsViewModelProtocol {
    var contacts: Variable<[RemoteUserViewModel]> { get set }
    func getContacts() -> Promise<Void>
    func addToContacts(_ user: RemoteUserViewModel) -> Promise<Void>
    func verifyContact(_ user: RemoteUserViewModel) -> Promise<Void>
    func removeFromContacts(_ user: RemoteUserViewModel) -> Promise<Void>
    
    var hasUnreadMessages: Variable<Bool> { get set }
    func updateHasUnreadMessages()
    
    func clear()
}

class ContactsViewModel: BaseViewModel, ContactsViewModelProtocol {
    
    private var contactsService: ContactsService!
    private var messagingService: MessagingService!
    private var rxDisposeBag = DisposeBag()
    
    private let kLastMessageTimestampUpdateFrequency = 20.0
    private var lastMessageTimestampTimer: Timer?
    
    var contacts = Variable<[RemoteUserViewModel]>([])
    var hasUnreadMessages = Variable<Bool>(false)

    init(contactsService: ContactsService, messagingService: MessagingService, repository: Repository) {
        super.init()
        self.contactsService = contactsService
        self.messagingService = messagingService
        self.repository = repository
        self.contacts.asObservable()
            .skip(2) // First 2 events are init and set from local copy. They shouldn't be handled.
            .bind { [weak self] contacts in
                self?.refreshContactsStatuses()
                self?.updateLastMessagesForContacts()
                self?.updateLastDataTimer()
            }
            .disposed(by: self.rxDisposeBag)
    }
        
    func getContacts() -> Promise<Void> {
        if let localContacts = self.repository.loadLocalContacts() {
            self.contacts.value = localContacts
        }
        return contactsService.getContacts()
            .then { loadedContacts -> Void in
                self.mergeMessagesFromLocalContacts(to: loadedContacts)
                self.repository.updateLocalContacts(with: loadedContacts)
                self.contacts.value = loadedContacts
            }
    }
    
    func addToContacts(_ user: RemoteUserViewModel) -> Promise<Void> {
        return self.contactsService.addToContacts(user.username)
            .then { _ -> Void in
                self.contacts.value.append(user)
                self.repository.saveLocalContact(user)
            }
    }
    
    func verifyContact(_ user: RemoteUserViewModel) -> Promise<Void> {
        return self.contactsService.verifyContact(user.username)
            .then { _ -> Void in
                self.repository.performInRealm { user.verified = true }
                self.contacts.value = self.contacts.value
            }
    }
    
    func removeFromContacts(_ user: RemoteUserViewModel) -> Promise<Void> {
        return self.contactsService.removeFromContacts(user.username)
            .then { _ -> Void in
                self.contacts.value = self.contacts.value.filter { $0.username != user.username }
                self.repository.deleteLocalContact(user)
            }
    }
    
    func updateHasUnreadMessages() {
        var hasUnread = false
        self.contacts.value.forEach { $0.hasUnreadMessages.value ? hasUnread = true : () }
        guard self.hasUnreadMessages.value != hasUnread else { return }
        self.hasUnreadMessages.value = hasUnread
    }
    
    func clear() {
        self.contacts.value.removeAll()
    }
    
    // MARK: - Override
    
    override func onApplicationBecomeActive() {
        updateUnverifiedContants()
    }
    
    // MARK: - Private
    
    @discardableResult
    private func refreshContactsStatuses() -> Promise<Void> {
        var statusCheckPromises = [Promise<Void>]()
        for contact in self.contacts.value {
            guard contact.verified else { continue }
            let statusCheckPromise = self.checkIsOnline(contact.username)
                .then { contact.isOnline.value = $0 }
            statusCheckPromises.append(statusCheckPromise)
        }
        return when(fulfilled: statusCheckPromises)
    }
    
    @discardableResult
    private func updateLastMessagesForContacts() -> Promise<Void> {
        var lastMessagePromises = [Promise<Void>]()
        for contact in self.contacts.value {
            guard contact.verified else { continue }
            let messagePromise = self.messagingService.getLastMessage(with: contact.username)
                .then { message -> Void in
                    guard let msg = message, msg.id != contact.messages.first?.id else { return }
                    self.repository.performInRealm { contact.messages.insert(msg, at: 0) }
                }
            lastMessagePromises.append(messagePromise)
        }
        return when(fulfilled: lastMessagePromises)
    }
    
    @discardableResult
    private func updateUnverifiedContants() -> Promise<Void> {
        return contactsService.getContacts()
            .then { loadedContacts -> Void in
                let loadedUnverifiedContacts = loadedContacts.filter { !$0.verified }
                var contacts = self.contacts.value.filter { $0.verified }
                contacts.append(contentsOf: loadedUnverifiedContacts)
                self.repository.updateLocalContacts(with: contacts)
                self.contacts.value = contacts
        }
    }
    
    private func checkIsOnline(_ username: String) -> Promise<Bool> {
        return self.contactsService.checkIsOnline(username)
    }
    
    private func updateLastDataTimer() {
        let numberOfContacts = self.contacts.value.count
        if numberOfContacts > 0 && self.lastMessageTimestampTimer == nil {
            self.lastMessageTimestampTimer = Timer.scheduledTimer(
                timeInterval: kLastMessageTimestampUpdateFrequency,
                target: self,
                selector: #selector(onRefreshDataTimerTick),
                userInfo: nil,
                repeats: true)
        } else if numberOfContacts == 0 {
            self.lastMessageTimestampTimer?.invalidate()
            self.lastMessageTimestampTimer = nil
        }
    }
    
    @objc private func onRefreshDataTimerTick() {
        self.contacts.value.forEach { $0.verified ? $0.refreshLastMessageTextAndDate() : () }
    }
    
    /*
     *  Remote contacts are saved in the repository and updated with messages
     *  When requested on login, contacts list is received from server without messages
     *  This method merges saved contacts with received ones to keep the messages
     */
    private func mergeMessagesFromLocalContacts(to contacts: [RemoteUserViewModel]) {
        guard let oldContacts = self.repository.loadLocalContacts() else { return }
        for newContact in contacts {
            guard let savedContact = oldContacts.first(where: { newContact.username == $0.username })
                else { continue }
            repository.performInRealm { newContact.messages = savedContact.messages }
        }
    }
}

extension ContactsViewModel: WSConnectionServiceDependable {
    
    func onConnectionEstablished() { }
    
    func onConnectionLost() { }
    
    func handleServerEvent(_ type: ServerEventType, payload: Any) {
        switch type {
        case .contactStatusUpdated:
            guard let status = Status.extract(from: payload),
                let contact = self.contacts.value.first(where: { $0.username == status.username })
                else { return }
            contact.isOnline.value = status.isOnline
        case .newMessage:
            guard let message = Message.extract(from: payload, localUserName: self.currentUsername),
                let contact = self.contacts.value.first(where: { $0.username == message.from })
                else { return }
            contact.hasUnreadMessages.value = true
            repository.performInRealm { contact.messages.insert(message, at: 0) }
            self.hasUnreadMessages.value = true
        case .messagesDeleted:
            guard let deletedIds = payload as? [String] else { return }
            self.contacts.value.forEach { contact in
                guard let lastMessage = contact.lastMessage.value, deletedIds.contains(lastMessage.id!)
                    else { return }
                self.repository.performInRealm { lastMessage.setAsDeleted() }
                contact.refreshLastMessageTextAndDate()
            }
        case .conversationRequest:
            updateUnverifiedContants()
        }
    }
    
}
