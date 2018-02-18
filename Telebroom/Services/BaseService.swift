//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import Foundation

class BaseService {
    
    var repository: Repository!
    var contentApi: ContentApi!
    
    func inject(_ repository: Repository, _ contentApi: ContentApi) -> Self {
        self.repository = repository
        self.contentApi = contentApi
        return self
    }

}
