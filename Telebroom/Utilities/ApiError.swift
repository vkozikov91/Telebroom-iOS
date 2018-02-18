//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import Foundation
import PromiseKit

enum ApiError: Error {
    
    case serverError
    case noConnection
    case serverUnreachable
    case unauthorized
    
    case wrongCredentials
    case usernameInUse
    
    var localizedDescription: String {
        switch self {
        case .serverError:
            return "Services cannot fulfil the request right now"
        case .noConnection:
            return "Not Internet Connection"
        case .serverUnreachable:
            return "Services are temporary out of service"
        case .unauthorized:
            return "Looks like you have been unauthorized"
        case .wrongCredentials:
            return "Username and/or password are incorrect"
        case .usernameInUse:
            return "This username is alredy registered"
        }
    }
    
    init(error: Error, httpCode: Int?, httpData: Data?) {
        print("HTTP Response: ", (httpCode ?? "none"));
        print("Code: ", (error as NSError).code)
        if httpCode == 500 {
            self = .serverError
        } else if httpCode == 401 {
            self = .unauthorized
        } else {
            let code = (error as NSError).code
            if code == 0 || code == -1009 {
                self = .noConnection
            } else if code == -1004 {
                self = .serverUnreachable
            } else if let errorFromMessage = ApiError(data: httpData) {
                self = errorFromMessage
            } else {
                self = .serverError
            }
        }
    }
    
    private init?(data: Data?) {
        guard let data = data, let message = String(data: data, encoding: .utf8)
            else { return nil }
        switch message {
        case "/WRONG_CREDENTIALS/":
            self = .wrongCredentials
        case "/USERNAME_IN_USE/":
            self = .usernameInUse
        default:
            return nil
        }
    }
}
