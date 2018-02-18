//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit
import PromiseKit

typealias SendImageResponse = (msgId: String, imageText: String)

class MessagingService: BaseService {
    
    func getLatestMessages(with username: String, pageSize: Int) -> Promise<[Message]> {
        let request = ApiRequest.getMessages(remoteUser: username, fromDate: "", pageSize: pageSize)
        let loadLatestRequestPromise: Promise<[Message]> = contentApi.request(request)
        return loadLatestRequestPromise
            .then { self.defineMessagesDirectionAndType($0, remoteUserName: username) }
    }
    
    func getMessages(with username: String, before timestamp: String, pageSize: Int) -> Promise<[Message]> {
        let request = ApiRequest.getMessages(remoteUser: username, fromDate: timestamp, pageSize: pageSize)
        let loadMessagesRequestPromise: Promise<[Message]> = contentApi.request(request)
        return loadMessagesRequestPromise
            .then { self.defineMessagesDirectionAndType($0, remoteUserName: username) }
    }
    
    func sendMessage(_ message: Message) -> Promise<Void> {
        let r = ApiRequest.sendMessage(remoteUser: message.to, text: message.text)
        return contentApi.request(r)
            .then { id -> Void in
                self.repository.performInRealm { message.id = id }
            }
    }
    
    func sendImage(_ image: UIImage, to username: String) -> Promise<SendImageResponse> {
        let jpegData = UIImageJPEGRepresentation(image, 0.5)!
        return contentApi.upload(ApiRequest.sendImage(remoteUser: username), data: jpegData)
            .then(execute: extractImageAndIdFromSendImageResponse)
    }
    
    func deleteMessages(with username: String, ids: [String]) -> Promise<Void> {
        return contentApi.request(ApiRequest.deleteMessages(remoteUser: username, ids: ids)).asVoid()
    }
    
    func getLastMessage(with username: String) -> Promise<Message?> {
        return self.getLatestMessages(with: username, pageSize: 1)
            .then { self.defineMessagesDirectionAndType($0, remoteUserName: username).first }
    }
    
    
    // MARK: - Private
    
    private func extractImageAndIdFromSendImageResponse(_ response: Any) -> Promise<SendImageResponse> {
        return Promise { fulfill, reject in
            guard let dictionary = response as? Dictionary<String, String>,
                let id = dictionary["id"],
                let imageText = dictionary["imageText"]
                else {
                    reject(NSError.defaultError)
                    return
            }
            let msgInfo: SendImageResponse = (msgId: id, imageText: imageText)
            fulfill(msgInfo)
        }
    }
    
    private func defineMessagesDirectionAndType(_ messages: [Message], remoteUserName: String) -> [Message] {
        for msg in messages {
            msg.defineDirection(remoteUserName: remoteUserName)
            msg.defineType()
        }
        return messages
    }
    
}
