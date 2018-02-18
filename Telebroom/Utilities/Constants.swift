//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import Foundation

class Constants {
    
    private static let SERVER_IP_ADDRESS = "192.168.0.1"
    
    static let SERVER_API_ADDRESS = "http://" + SERVER_IP_ADDRESS + ":8081"
    static let SERVER_WS_ADDRESS = "ws://" + SERVER_IP_ADDRESS + ":3000"
    
    struct transitions {
        static let TAB_TRANSITION_DURATION = 0.3
        static let CONVERSATION_TRANSITION_APPEAR_DURATION = 0.5
        static let CONVERSATION_TRANSITION_DISAPPEAR_DURATION = 0.3
        static let BLUR_NAVIGATION_TRANSITION_DURATION = 1.0
        static let SCALE_DISSOLVE_TRANSITION_DURATION = 1.0
    }
    
    struct segueIDs {
        static let mainToConversation = "MainToConversationSegue"
        static let introToMain = "IntroToMainSegue"
        static let introToLogin = "IntroToLoginSegue"
        static let loginToMain = "LoginToMainSegue"
        static let searchToDetails = "SearchToDetailsSegue"
        static let profileToEdit = "ProfileToEditCredentialsSegue"
        
        static let unwindEditCredentialsToProfile = "UnwindEditCredentialsToProfileSegue"
        static let unwindConversationToContacts = "UnwindConversationToContactsSegue"
    }
}
