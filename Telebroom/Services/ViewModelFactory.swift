//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import Foundation

class ViewModelFactory {

    private var serviceFactory: ServiceFactory
    private var repository: Repository
    
    private var contactsViewModel: ContactsViewModel?
    private var messagingViewModel: MessagingViewModel?
    
    init(serviceFactory: ServiceFactory, repository: Repository) {
        self.serviceFactory = serviceFactory
        self.repository = repository
    }
    
    func getSearchViewModel() -> SearchViewModel {
        return SearchViewModel(searchService: self.serviceFactory.getSearchService()).inject(self.repository)
    }
    
    func getContactsViewModel() -> ContactsViewModel {
        if self.contactsViewModel == nil {
            self.contactsViewModel = ContactsViewModel(
                contactsService: self.serviceFactory.getContactsService(),
                messagingService: self.serviceFactory.getMessagingService(),
                repository: self.repository)
            self.serviceFactory.getWSCService().contactsDelegate = self.contactsViewModel
        }
        return self.contactsViewModel!
    }
    
    func getMessagingViewModel() -> MessagingViewModel {
        if self.messagingViewModel == nil {
            self.messagingViewModel = MessagingViewModel(
                messagingService: self.serviceFactory.getMessagingService(),
                repository: self.repository)
            self.serviceFactory.getWSCService().messagingDelegate = self.messagingViewModel
        }
        return self.messagingViewModel!
    }
    
    func reset() {
        self.contactsViewModel?.clear()
        self.contactsViewModel = nil
        self.messagingViewModel?.clear()
        self.messagingViewModel = nil
    }
    
}
