//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit
import Starscream

enum ServerEventType: String {
    case newMessage = "msg"
    case messagesDeleted = "dlt"
    case contactStatusUpdated = "sta"
    case conversationRequest = "crq"
}

private enum SocketConnectionState {
    case disconnected
    case connecting
    case connected
    case reconnecting
    case suspended
}

protocol WSConnectionServiceDependable: class {
    func onConnectionEstablished()
    func onConnectionLost()
    func handleServerEvent(_ type: ServerEventType, payload: Any)
}

/*
 * MARK: -
 *
 * Service is responsible for maintaining Web Sockets connection with the server,
 * receiving events, parsing and notyfying associated dependable delegates
 */

class WSConnectionService: BaseService {
    
    private var socket: WebSocket!
    private var state: SocketConnectionState = .disconnected {
        didSet { self.handleConnectionStateChange(from: oldValue, to: state) }
    }
    
    private var currentUsername: String {
        return self.repository.localUser!.username
    }
    
    private var connectCompletionHandler: ((Bool) -> Void)?
    
    
    // MARK: - Public
    
    weak var contactsDelegate: WSConnectionServiceDependable?
    weak var messagingDelegate: WSConnectionServiceDependable?
    
    override init() {
        super.init()
        self.configureSocketConnection()
        self.subscribeToAppState()
    }
    
    func connect(completionHandler: ((Bool) -> Void)? = nil) {
        if let completionHandler = completionHandler {
            self.connectCompletionHandler = completionHandler
        }
        self.socket.connect()
        self.state = .connecting
    }
    
    func disconnect() {
        self.state = .disconnected
        self.socket.disconnect()
        self.contactsDelegate?.onConnectionLost()
        self.messagingDelegate?.onConnectionLost()
    }
    
    private func handleConnectionStateChange(from: SocketConnectionState, to: SocketConnectionState) {
        print("Web Sockets state changed : \(from) => \(to)")
    }
    
    
    // MARK: - Private
    
    private func configureSocketConnection() {
        socket = WebSocket(url: URL(string: Constants.SERVER_WS_ADDRESS)!)
        socket.onConnect = { [weak self] in
            guard let `self` = self else { return }
            switch self.state {
            case .connecting:
                print("Successfully established connection with server")
                self.connectCompletionHandler?(true)
                self.connectCompletionHandler = nil
            case .reconnecting:
                print("Reestablished connection with server")
            default:
                return
            }
            self.socket.write(string: "auth::\(self.currentUsername)")
            self.state = .connected
        }
        socket.onDisconnect = { [weak self] error -> Void in
            guard let `self` = self else { return }
            switch self.state {
            case .connecting:
                self.state = .disconnected
                print("[!] Failed to establish connection to server")
                self.connectCompletionHandler?(false)
                self.connectCompletionHandler = nil
            case .connected, .reconnecting:
                self.state = .reconnecting
                print("Lost connection with server. Reconnecting ... ")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    self.socket.connect()
                })
            default:
                break
            }
        }
        socket.onText = { [weak self] (text: String) in
            print("Received Text: \(text)")
            self?.parseServerEventAndPublish(text)
        }
    }
    
    private func parseServerEventAndPublish(_ text: String) {
        guard let textData = text.data(using: .utf8),
            let jsonData = try? JSONSerialization.jsonObject(with: textData,
                                                             options: []) as? Dictionary<String, Any>,
            let rawType = jsonData?["type"] as? String,
            let type = ServerEventType.init(rawValue: rawType),
            let payload = jsonData?["data"]
        else { return }
        
        switch type {
        case .newMessage:
            self.messagingDelegate?.handleServerEvent(.newMessage, payload: payload)
            self.contactsDelegate?.handleServerEvent(.newMessage, payload: payload)
        case .messagesDeleted:
            self.messagingDelegate?.handleServerEvent(.messagesDeleted, payload: payload)
            self.contactsDelegate?.handleServerEvent(.messagesDeleted, payload: payload)
        case .contactStatusUpdated:
            self.contactsDelegate?.handleServerEvent(.contactStatusUpdated, payload: payload)
        case .conversationRequest:
            self.contactsDelegate?.handleServerEvent(.conversationRequest, payload: payload)
        }
    }
    
    private func subscribeToAppState() {
        /*
         * More optimal is to subscribe to foreground -> background -> foreground transitions.
         * However, on iOS 11 the socket disconnected event sometimes is not received on server
         * when disconnect is fulfilled when entering background. On iOS 10 it works correctly.
         * Thus resign/become active is used instead.
         */
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onAppResignActive(_:)),
            name: .UIApplicationWillResignActive,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onAppBecomeActive(_:)),
            name: .UIApplicationDidBecomeActive,
            object: nil)
    }
    
    @objc private func onAppResignActive(_ notification: Notification) {
        if self.state != .disconnected {
            disconnect()
            self.state = .suspended
        }
    }
    
    @objc private func onAppBecomeActive(_ notification: Notification) {
        if self.state == .suspended {
            connect()
            self.state = .reconnecting
        }
    }
    
    deinit {
        disconnect()
    }
    
}
