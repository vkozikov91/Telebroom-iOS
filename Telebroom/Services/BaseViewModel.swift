//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import Foundation
import RxSwift

class BaseViewModel {
    var repository: Repository!
    var currentUsername: String {
        guard let user = repository.localUser else {
            fatalError("Trying to access local user when not logged in")
        }
        return user.username
    }
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onApplicationBecomeActive),
            name: .UIApplicationDidBecomeActive,
            object: nil)
    }
    
    func inject(_ repository: Repository) -> Self {
        self.repository = repository
        return self
    }
    
    @objc open func onApplicationBecomeActive() { }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
