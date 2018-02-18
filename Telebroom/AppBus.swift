//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import Foundation

class AppBus {
    
    var pendingConversationUsername: String?
    
    func clearBus() {
        self.pendingConversationUsername = nil
    }
}
