//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import PromiseKit

class ContentApi {
    
    static let publicApiAddress = Constants.SERVER_API_ADDRESS
    static let authorizedApiAddress  = Constants.SERVER_API_ADDRESS + "/api/v1"
    
    private let repository: Repository
    
    private var authorizationHeader: [String: String] {
        return ["token": repository.localUser!.token]
    }
    
    // MARK: -
    
    init(repository: Repository) {
        self.repository = repository
    }
    
    func request<T>(_ request: ApiRequest) -> Promise<T> where T: BaseMappable {
        print("Request to \(request.path)")
        return Promise { fulfill, reject in
            Alamofire.request(request.asURL(),
                              method: request.method,
                              parameters: request.params,
                              headers: (request.requiresAuth ? self.authorizationHeader : nil))
                .validate()
                .responseObject { (response: DataResponse<T>) in
                    switch response.result {
                    case .success(_):
                        fulfill(response.result.value!)
                    case .failure(let error):
                        print(response.request?.url?.absoluteString ?? "")
                        print(response)
                        let apiError = ApiError(error: error,
                                                httpCode: response.response?.statusCode,
                                                httpData: response.data)
                        reject(apiError)
                    }
            }
        }
    }
    
    func request<T>(_ request: ApiRequest) -> Promise<[T]> where T: BaseMappable {
        print("Request to \(request.path)")
        return Promise { fulfill, reject in
            Alamofire.request(request.asURL(),
                              method: request.method,
                              parameters: request.params,
                              headers: (request.requiresAuth ? self.authorizationHeader : nil))
                .validate()
                .responseArray { (response: DataResponse<[T]>) in
                    switch response.result {
                    case .success(_):
                        fulfill(response.result.value!)
                    case .failure(let error):
                        print(response.request?.url?.absoluteString ?? "")
                        print(response)
                        let apiError = ApiError(error: error,
                                                httpCode: response.response?.statusCode,
                                                httpData: response.data)
                        reject(apiError)
                    }
            }
        }
    }
    
    func request(_ request: ApiRequest) -> Promise<String> {
        print("Request to \(request.path)")
        return Promise { fulfill, reject in
            Alamofire.request(request.asURL(),
                              method: request.method,
                              parameters: request.params,
                              headers: (request.requiresAuth ? self.authorizationHeader : nil))
                .validate()
                .responseString { (response) in
                    switch response.result {
                    case .success(_):
                        fulfill(response.result.value!)
                    case .failure(let error):
                        print(response.request?.url?.absoluteString ?? "")
                        print(response)
                        let apiError = ApiError(error: error,
                                                httpCode: response.response?.statusCode,
                                                httpData: response.data)
                        reject(apiError)
                    }
            }
        }
    }
    
    func upload(_ request: ApiRequest, data: Data) -> Promise<Any> {
        return Promise { fulfill, reject in
            Alamofire.upload(multipartFormData: { mData in
                mData.append(data,
                             withName: String(describing: request.params!["name"]!),
                             fileName: String(describing: request.params!["filename"]!),
                             mimeType: String(describing: request.params!["mimeType"]!))
                request.params?
                    .filter { !["name", "filename", "mimeType"].contains($0.key) }
                    .forEach { mData.append(String(describing: $0.value).toUTF8(), withName: $0.key) }
            }, to: request.asURL(),
               headers: self.authorizationHeader) { (result) in
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON(completionHandler: { (response) in
                        if let resp = response.result.value {
                            fulfill(resp)
                        } else {
                            let apiError = ApiError(error: response.error!,
                                                    httpCode: response.response?.statusCode,
                                                    httpData: response.data)
                            reject(apiError)
                        }
                    })
                case .failure(let encodingError):
                    let apiError = ApiError(error: encodingError, httpCode: nil, httpData: nil)
                    reject(apiError)
                }
            }
        }
    }
    
    func stopAllRequests() {
        let sessionManager = Alamofire.SessionManager.default
        sessionManager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            dataTasks.forEach { $0.cancel() }
            uploadTasks.forEach { $0.cancel() }
            downloadTasks.forEach { $0.cancel() }
        }
    }
    
}
