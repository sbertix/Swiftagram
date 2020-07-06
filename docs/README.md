# Swiftagram
[![Swift](https://img.shields.io/badge/Swift-5.1-%23DE5C43?style=flat&logo=swift)](https://swift.org)
[![codecov](https://codecov.io/gh/sbertix/Swiftagram/branch/master/graph/badge.svg)](https://codecov.io/gh/sbertix/Swiftagram)
[![Telegram](https://img.shields.io/badge/Telegram-Swiftagram-blue?style=flat&logo=telegram)](https://t.me/swiftagram)

**Swiftagram** is a client for [**Instagram**](https://instagram.com) written entirely in **Swift**.

<br/>

> How does it work?  

**Swiftagram** relies on Instagram unofficial private APIs, used internally in the Android and iOS apps.  

This is because Instagram's **official APIs**, both the [**Instagram Basic Display API**](https://developers.facebook.com/docs/instagram-basic-display-api) and the [**Instagram Graph API**](https://developers.facebook.com/docs/instagram-api/), are either lacking support for even the most mundane of features or limited to a small audience (e.g. _Professional_, i.e. _Creator_ and _Influencer_, accounts).  

> Do I need an API token?

**Swiftagram** requires no token or registration.\
Unofficial APIs, though, are not authorized by Instagram for external use: use them at your own risk.

> Where can I use this?

**Swiftagram** supports **iOS**, **macOS**, **watchOS**, **tvOS** and **Linux**.

> What's **SwiftagramCrypto**?

Apps using encryption require specific disclosure before submission to the App Store.\
Although **Swiftagram** cannot be considered App Store safe, we still think it's wise to separate everything requiring cryptography into their own target library, named **SwiftagramCrypto**.\
Other than `KeychainStorage`, the prefered way to store `Secret`s, some `Endpoint`s are **SwiftagramCrypto** only.

<details><summary><strong>SwiftagramCrypto</strong>-specific endpoints</summary>
    <p>
        
- `Endoint.Feed`
    - `.stories(by:)`
- `Endpoint.Friendship`
    - `.follow(_:)`
    - `.unfollow(_:)`
    - `.remove(follower:)`
    - `.acceptRequest(from:)`
    - `.rejectRequest(from:)`
    - `.block(_:)`
    - `.unblock(_:)`
- `Endpoint.Media`
    - `.like(_:)`
    - `.unlike(_:)`
    </p>
</details>

## Status
![Status](https://github.com/sbertix/Swiftagram/workflows/master/badge.svg)
[![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/sbertix/Swiftagram)](https://github.com/sbertix/Swiftagram/wiki)

> What's next?

Check out our [milestones](https://github.com/sbertix/Swiftagram/milestones), [issues](https://github.com/sbertix/Swiftagram/issues) and the "WIP" [dashboard](https://github.com/sbertix/Swiftagram/projects/1).

[Pull requests](https://github.com/sbertix/Swiftagram/pulls) are more than welcome.\
Just remember to refer to our [guidelines](CONTRIBUTING.md) and [Code of Conduct](CODE_OF_CONDUCT.md), when you contribute.


## Installation
### Swift Package Manager (Xcode 11 and above)
1. Select `File`/`Swift Packages`/`Add Package Dependency…` from the menu.
1. Paste `https://github.com/sbertix/Swiftagram.git`.
1. Follow the steps.
1. Add **SwiftagramCrypto** together with **Swiftagram** for the full experience.

> Why not CocoaPods, or Carthage, or ~blank~?

Supporting multiple _dependency managers_ makes maintaining a library exponentially more complicated and time consuming.\
Furthermore, with the integration of the **Swift Package Manager** in **Xcode 11** and greater, we expect the need for alternative solutions to fade quickly.

<details><summary><strong>Targets</strong></summary>
    <p>
        
- **Swiftagram** depends on [**ComposableRequest**](https://github.com/sbertix/ComposableRequest), an HTTP client originally integrated in **Swiftagram**., and it's the core library.\
It supports [`Combine`](https://developer.apple.com/documentation/combine) `Publisher`s out of the box.

- **SwiftagramCrypto**, depending on [**CryptoSwift**](https://github.com/krzyzanowskim/CryptoSwift) and [**KeychainSwift**](https://github.com/evgenyneu/keychain-swift), can be added to **Swiftagram** to extend its functionality, accessing the safer `KeychainStorage` and encrypted `Endpoint`s (e.g. `Endpoint.Friendship.follow`, `Endpoint.Friendship.unfollow`).
    </p>
</details>

## Usage
Check out our [Examples](Examples) or visit the (_auto-generated_) [Documentation](https://sbertix.github.io/Swiftagram) to learn about use cases.  

### Authentication
Authentication is provided through conformance to the `Authenticator` protocol, which, on success, returns a `Secret` containing all the cookies needed to sign an `Endpoint`'s request.

The library comes with two concrete implementations.
- ~[`BasicAuthenticator`](https://sbertix.github.io/Swiftagram/Classes/BasicAuthenticator.html) requires _username_ and _password_, and includes support for checkpoints and two factor authentication.~.
- [`WebViewAuthenticator`](https://sbertix.github.io/Swiftagram/Classes/WebViewAuthenticator.html), available for **iOS 11**+ and **macOS 10.13**+, relying on a `WKWebView` for fetching cookies.

### Caching
Caching of `Secret`s is provided through conformance to the `Storage` protocol.  

The library comes with several concrete implementations.  
- `TransientStorage` should be used when no caching is necessary.  
- `UserDefaultsStorage` allows for faster, out-of-the-box, testing, although it's not recommended for production as private cookies are not encoded.  
- `KeychainStorage`, part of **SwiftagramCrypto**, (**preferred**) stores them safely in the user's keychain.  

### Request
> How can I bypass Instagram "spam" filter, and make them believe I'm not actually a bot?

Just set the default `waiting` time in the `Requester` to something greater than `0`.

```swift
import ComposableRequest
import Swiftagram
import SwiftagramCrypto

// Somewhere in your code, for instance in your `AppDelegate`, set a new `default` `Requester`.
// `O.5` to `1.5` seconds is a long enough time, usually.
// `Requester.instagram` deals about it for you.
Requester.default = .instagram
```

Or just create a custom `Requester` and pass it to every single request you make.  
<br/>

> What if I wanna know the basic info about a profile?

All you need is the user identifier and a valid `Secret`.

```swift
let identifier: String = /* the profile identifier */
let secret: Secret = /* the authentication response */

// Perform the request.
Endpoint.User.summary(for: identifier)
    .unlocking(with: secret)
    .task {
        // Do something here.
    })
    .resume() // Strongly referenced by default, no need to worry about it.
```
<br/>

> What about cancelling an ongoing request?

Easy!

```swift
let secret: Secret = /* the authentication response */

// Perform the request.
let task = Endpoint.Friendship.following(secret.id)
    .unlocking(with: secret)
    .task(maxLength: 10,
          onComplete: { _ in },
          onChange: { _ in  
            // Do something here.
    })
    .resume() // Exhaust 10 pages of followers.

// Cancel it.
task?.cancel()
```
<br/>

>  What about loading the next page?

Just `resume` it once more. 
If it's still fetching, nothing's gonna happen. But if it's not and there are still more pages to be fetched, a new one will be requested.  
