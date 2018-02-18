//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

class ServiceFactory {
    
    private var repository: Repository
    private var contentApi: ContentApi
    private var socketsService: WSConnectionService
    private var pushService: PushNotificationsService
    
    init(repository: Repository) {
        self.repository = repository
        self.contentApi = ContentApi(repository: self.repository)
        self.socketsService = WSConnectionService().inject(repository, contentApi)
        self.pushService = PushNotificationsService().inject(repository, contentApi)
    }
    
    func getProfileService() -> ProfileService {
        return ProfileService().inject(repository, contentApi).inject(socketsService, pushService)
    }
    
    func getContactsService() -> ContactsService {
        return ContactsService().inject(repository, contentApi)
    }
    
    func getMessagingService() -> MessagingService {
        return MessagingService().inject(repository, contentApi)
    }
    
    func getSearchService() -> SearchService {
        return SearchService().inject(repository, contentApi)
    }
    
    func getWSCService() -> WSConnectionService {
        return self.socketsService
    }
    
    func getPushNotificationsService() -> PushNotificationsService {
        return self.pushService
    }
}
