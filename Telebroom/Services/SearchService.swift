//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import Foundation
import PromiseKit

class SearchService: BaseService {
    
    func search(text: String) -> Promise<[RemoteUserViewModel]> {
        return contentApi.request(ApiRequest.search(query: text))
    }
}
