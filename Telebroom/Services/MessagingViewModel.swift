//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit
import PromiseKit
import RxSwift
import RxCocoa

protocol MessagingViewModelProtocol {
    var messages: Variable<[Message]> { get set }
    var noMoreMessagesToFetch: Variable<Bool> { get set }
    var remoteUser: RemoteUserViewModel? { get set }
    func loadLatestMessages() -> Promise<Void>
    func loadMoreMessages() -> Promise<Void>
    func sendMessage(_ text: String) -> Promise<Void>
    func sendImage(_ image: UIImage) -> Promise<Void>
    func deleteMessages(ids: [String]) -> Promise<Void>
    func clear()
}

class MessagingViewModel: BaseViewModel, MessagingViewModelProtocol {
    
    private let kMessagesPageSize = 20
    private var messagingService: MessagingService!
    
    var messages = Variable<[Message]>([])
    var noMoreMessagesToFetch = Variable<Bool>(false)
    
    var remoteUser: RemoteUserViewModel? {
        didSet { remoteUser == nil ? messages.value.removeAll() : () }
    }
    
    init(messagingService: MessagingService, repository: Repository) {
        super.init()
        self.messagingService = messagingService
        self.repository = repository
    }
        
    func loadLatestMessages() -> Promise<Void> {
        guard let contact = self.remoteUser else { return .void }
        
        // Show messages from local copy while updating the messages
        if contact.messages.count > 0 {
            self.messages.value = Array(contact.messages)
        }
        
        return messagingService.getLatestMessages(with: contact.username, pageSize: kMessagesPageSize)
            .then { messages -> Void in
                self.messages.value = messages
                self.updateRepository()
                self.updateNoMoreMessagesIfNeeded(loadedPortionSize: messages.count)
            }
    }
    
    func loadMoreMessages() -> Promise<Void> {
        guard let contact = self.remoteUser else { return .void }
        return messagingService.getMessages(with: contact.username,
                                            before: self.messages.value.last!.timeStampISOString,
                                            pageSize: kMessagesPageSize)
            .then { messages -> Void in
                self.messages.value.append(contentsOf: messages)
                self.updateRepository()
                self.updateNoMoreMessagesIfNeeded(loadedPortionSize: messages.count)
            }
    }
    
    func sendMessage(_ text: String) -> Promise<Void> {
        guard let contact = self.remoteUser else { return .void }
        
        // Local message is displayed first to conсeal server response delay
        let message = self.createMessageTemplate(type: .text, content: text)
        self.messages.value.insert(message, at: 0)
        
        return self.messagingService.sendMessage(message)
            .then(execute: self.updateRepository)
            .recover(execute: { error -> Promise<Void> in
                self.messages.value = Array(contact.messages) // Restore messages from saved copy
                throw error
            })
    }
    
    func sendImage(_ image: UIImage) -> Promise<Void> {
        guard let contact = self.remoteUser else { return .void }
        return self.messagingService.sendImage(image, to: contact.username)
            .then { sendImageResponse -> Void in
                let message = self.createMessageTemplate(type: .image,
                                                         content: sendImageResponse.imageText)
                message.id = sendImageResponse.msgId
                self.messages.value.insert(message, at: 0)
                self.updateRepository()
        }
    }
    
    func deleteMessages(ids: [String]) -> Promise<Void> {
        guard let contact = self.remoteUser else { return .void }
        return self.messagingService.deleteMessages(with: contact.username, ids: ids)
            .then { _ -> Void in
                self.messages.value.forEach({ message in
                    guard let id = message.id, ids.contains(id) else { return }
                    self.repository.performInRealm { message.setAsDeleted() }
                })
                self.refreshMessages()
                contact.refreshLastMessageTextAndDate()
            }
    }
    
    func clear() {
        self.remoteUser = nil
        self.messages.value.removeAll()
    }
    
    // MARK: - Override
    
    override func onApplicationBecomeActive() {
        getNewMessages()
    }
    
    // MARK: - Private
    
    @discardableResult
    private func getNewMessages() -> Promise<Void> {
        guard let contact = self.remoteUser, let currentLastMessage = self.messages.value.first
            else { return .void }
        
        // Reload the latest messages and insert those that are not present in the current list
        return messagingService.getLatestMessages(with: contact.username, pageSize: kMessagesPageSize)
            .then { messages -> Void in
                var newMessagesOnly = [Message]()
                for message in messages {
                    if message.id! != currentLastMessage.id! {
                        newMessagesOnly.append(message)
                    } else {
                        break
                    }
                }
                self.messages.value.insert(contentsOf: newMessagesOnly, at: 0)
                self.refreshMessages() // Workaround to force update the tableView
                self.updateRepository()
        }
    }
    
    private func updateRepository() {
        guard let contact = self.remoteUser else { return }
        self.repository.performInRealm { contact.messages = self.messages.value }
    }
    
    private func createMessageTemplate(type: MessageType, content: String) -> Message {
        let message = Message()
        message.to = self.remoteUser!.username
        message.from = self.currentUsername
        message.text = content
        message.type = type
        message.isIncoming = false
        message.timeStamp = Date()
        return message
    }
    
    private func refreshMessages() {
        self.messages.value = self.messages.value
    }
    
    private func updateNoMoreMessagesIfNeeded(loadedPortionSize: Int) {
        let isFinalPortion = (loadedPortionSize < self.kMessagesPageSize)
        self.noMoreMessagesToFetch.value = isFinalPortion
    }
}

extension MessagingViewModel: WSConnectionServiceDependable {
    
    func onConnectionEstablished() { }
    
    func onConnectionLost() { }
    
    func handleServerEvent(_ type: ServerEventType, payload: Any) {
        switch type {
        case .newMessage:
            guard let message = Message.extract(from: payload, localUserName: self.currentUsername),
                message.isIncoming
                else { return }
            self.messages.value.insert(message, at: 0)
            self.updateRepository()
        case .messagesDeleted:
            guard let deletedIds = payload as? [String] else { return }
            self.messages.value.forEach { message in
                guard let id = message.id, deletedIds.contains(id) else { return }
                self.repository.performInRealm { message.setAsDeleted() }
            }
            self.updateRepository()
            self.refreshMessages()
        default:
            break
        }
    }
    
}
