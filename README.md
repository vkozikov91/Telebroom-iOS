# Telebroom - iOS Client
Telebroom is a project of a messenger applications infrastructure that at the moment consists of [iOS client](https://github.com/vkozikov91/Telebroom-iOS) and [Node.js](https://github.com/vkozikov91/Telebroom-Server) server. It's not a rigid product ready for mass deployment, because originally it was a playground to test how different frameworks and architectures play all together. However it has gradually grown into relatively 'fully fledged' project.

The following features are bestowed upon Telebroom users:
- **Sign up, login** - authorize with username and password;
- **Edit credentials** - change avatar, first/second name;
- **Search for contacts** - by part of username or any other name;
- **Send conversation requests** - once a conversation gets started with a new contact, the interlocuter is notified;
- **Send messages with text or images** - write texts, attach images from gallery or camera;
- **Delete sent messages** - if client 'A' deletes a message, it's deleted on 'B' side as well;
- **See contacts presence** - realtime online/offline status representation;
- **Receive messages when the app is not in foreground** - offline users are notified with Push Notifications;

## iOS Client:

- Started in Swift 3.0, migrated to Swift 4.0
- Architecture is built using the [MVVM](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel) pattern
- Application flaunts modern iOS UI features - custom UI elements, animations and animated screen transitions, blur effects etc.
- Promises-based error handling with affected data restoration and proper user notifying
- Project uses [Carthage](https://github.com/Carthage/Carthage) as dependency manager

### Main Used Frameworks:
- [**RxSwift**](https://github.com/ReactiveX/RxSwift) (ReactiveX) - provides binding features to implement MVVM
- [**Alamofire**](https://github.com/Alamofire/Alamofire) - REST API interraction;
- [**Starscream**](https://github.com/daltoniam/starscream) - WebSocket connection with the server. Used for realtime presence and new messages notifications when the interlocutor is online;
- [**Realm**](https://github.com/realm/realm-cocoa) - stores public user data, contacts and messages. Utterly useful for temporary displaying local data when loading is in progress or restoring corrupted data after request failure;
- [**PromiseKit**](https://github.com/mxcl/PromiseKit) - turns async methods and embedded callback piles into syntactic sugar code especially when collaborating with API and handling errors;
- [**Kingfisher**](https://github.com/onevcat/Kingfisher) - images caching for messages and user avatars;

## How it all works:
---
### Registration
When **signing up**/**logging in** with username and password the client receives an authentication token that is further used in requests to the server. When app is terminated and then launched again, it will try to **re-authorize** using this token. If token is still valid, then app logs in automatically.

![Register](https://raw.githubusercontent.com/vkozikov91/Telebroom-iOS/master/doc/register.gif)

Password is **not stored** on the client and sent in an encrypted state to the server. Received token is saved in Keychain and used in all requests that require auth. Global parameters such as user's first name, second name, contacts list and messages are cached and stored in Realm database. 

### Contacts
Each contact is displayed with avatar, name, last message text and timestamp (if available) and current status. All data is **updated automatically** in realtime and doesn't require any manual pull-to-refresh gestures.

![Contacts](https://raw.githubusercontent.com/vkozikov91/Telebroom-iOS/master/doc/mainscreen.png) 

### Profile
Profile screen allows the client to change first and second names, avatar and log out.

![PROFILE](https://raw.githubusercontent.com/vkozikov91/Telebroom-iOS/master/doc/profile.png)


### Search
New contacts can be added from the Search screen. Once a contact is added and a message is sent, the interlocutor gets notified about the new conversation. When selecting a conversation request a dialog appears to add the conversation originator to the contacts list.

![SEARCH](https://raw.githubusercontent.com/vkozikov91/Telebroom-iOS/master/doc/search.gif)

### Presence
Contacts are notified about user's current online/offline status in **realtime**.

![PRESENCE](https://raw.githubusercontent.com/vkozikov91/Telebroom-iOS/master/doc/presence.gif)

### Conversations
User can **send texts** and **images** from gallery or camera. When a conversation is open, saved copy of messages from previous session is displayed during the conversation update.

To reduce network delays when sending a message, it is immediately displayed for the sender without waiting for reply from server. If the request fails, data is reset from local copy.

![MESSAGING](https://raw.githubusercontent.com/vkozikov91/Telebroom-iOS/master/doc/messaging.gif)

Menu of Conversation screen provides options to **delete** sent messages (messages are deleted on both sides) or the interlocuter from contacts.

![Delete](https://raw.githubusercontent.com/vkozikov91/Telebroom-iOS/master/doc/delete.gif)

To optimize network usage, messages are loaded in sequential **pages**. Next page is loaded when scrolling reaches the last message of the current one.

### Push Notifications
During logging in the app registers for remote notifications (if permitted by user). Then Push token is sent to the server. Remote notifications are used when the app is not in foreground to send notifications about new messages or conversation requests. Once Push Notification is tapped, the app opens the associated conversation.

![Push Notifications](https://raw.githubusercontent.com/vkozikov91/Telebroom-iOS/master/doc/pushes.gif)

### Configuration
---
**Constants.swift**
```swift 
private static let SERVER_IP_ADDRESS
static let SERVER_API_ADDRESS
```
Change these constants to reference the IP address of the server and use _http_ or _https_ connection. Additional configuration may be required in networks with proxy servers, since the app hasn't been properly tested in such environments.

### License
---
MIT
