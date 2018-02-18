//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit
import PromiseKit
import RxSwift

class SearchViewModel: BaseViewModel {
    
    private var searchService: SearchService!
    
    var searchResults = Variable<[RemoteUserViewModel]>([])
    var onWillUpdateResults: VoidClosure?
    
    init(searchService: SearchService) {
        super.init()
        self.searchService = searchService
    }
    
    func search(text: String) -> Promise<Void> {
        return self.searchService.search(text: text).then { results -> Void in
            self.onWillUpdateResults?()
            self.searchResults.value = results
        }
    }
    
}
