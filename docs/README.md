<br />
<img alt="Header" src="https://github.com/sbertix/Swiftagram/blob/main/Resources/header.png" height="72" />
<br />

[![Swift](https://img.shields.io/badge/Swift-5.2-%23DE5C43?style=flat&logo=swift)](https://swift.org)
[![codecov](https://codecov.io/gh/sbertix/Swiftagram/branch/main/graph/badge.svg)](https://codecov.io/gh/sbertix/Swiftagram)
[![Telegram](https://img.shields.io/badge/Telegram-Swiftagram-blue?style=flat&logo=telegram)](https://t.me/swiftagram)
<br />
![iOS](https://img.shields.io/badge/iOS-13.0-DD5D43)
![macOS](https://img.shields.io/badge/macOS-10.15-DD5D43)
![tvOS](https://img.shields.io/badge/tvOS-13.0-DD5D43)
![watchOS](https://img.shields.io/badge/watchOS-6.0-DD5D43)

<br />

**Swiftagram** is a wrapper for [**Instagram**](https://instagram.com) Private API, written entirely in (modern) **Swift**.

**Instagram**'s official APIs, both the [*Instagram Basic Display API*](https://developers.facebook.com/docs/instagram-basic-display-api) and the [*Instagram Graph API*](https://developers.facebook.com/docs/instagram-api) — available for *Creator* and *Business* accounts alone, either lack support for the most mundane of features or limit their availability to a not large enough subset of profiles.

In order to bypass these limitations, **Swiftagram** relies on the API used internally by the Android and iOS official **Instagram** apps, requiring no _API token_, and allowing to reproduce virtually any action a user can take.
Please just bear in mind, as they're not authorized for external use, you're using them at your own risk.

<br />

> What's **SwiftagramCrypto**?

Relying on encryption usually requires specific disclosure, e.g. on submission to the **App Store**.

[Despite **Swiftagram**, as all libraries relying on unathorized third-party APIs, cannot be considered **App Store** safe](https://9to5mac.com/2020/08/27/apple-rejects-watch-for-tesla-app-as-it-starts-requiring-written-consent-for-third-party-api-use/), we still value separating everything depending on [encryption](https://developer.apple.com/documentation/security/complying_with_encryption_export_regulations) into its owen target library, we call **SwiftagramCrypto**.
Keep in mind features like `BasicAuthenticator`, a non-visual `Authenticator`, or `KeychainStorage`, the safe and preferred way to store `Secret`s, or even the ability to post on your feed and upload stories are **SwiftagramCrypto** only.

Please check out the _docs_ to find out more.

<p />

## Status
![push](https://github.com/sbertix/Swiftagram/workflows/push/badge.svg)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/sbertix/Swiftagram)

You can find all changelogs directly under every [release](https://github.com/sbertix/Swiftagram/releases), and if you care to be notified about future ones, don't forget to subscribe to our [Telegram channel](https://t.me/Swiftagram).

> What's next?

[Milestones](https://github.com/sbertix/Swiftagram/milestones), [issues](https://github.com/sbertix/Swiftagram/issues), as well as the [_WIP dashboard_](https://github.com/sbertix/Swiftagram/projects/1), are the best way to keep updated with active developement.

Feel free to contribute by sending a [pull request](https://github.com/sbertix/Swiftagram/pulls).
Just remember to refer to our [guidelines](CONTRIBUTING.md) and [Code of Conduct](CODE_OF_CONDUCT.md) beforehand.

<p />

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

- [**Swiftagram**](https://sbertix.github.io/Swiftagram/Swiftagram) depends on [**ComposableRequest**](https://github.com/sbertix/ComposableRequest), an HTTP client originally integrated in **Swiftagram**.\
It supports [`Combine`](https://developer.apple.com/documentation/combine) `Publisher`s and caching `Secret`s, through **ComposableStorage**, out-of-the-box.

- [**SwiftagramCrypto**](https://sbertix.github.io/Swiftagram/SwiftagramCrypto), depending on [**Swiftchain**](https//github.com/sbertix/Swiftchain) and a fork of [**SwCrypt**](https://github.com/sbertix/SwCrypt), can be imported together with **Swiftagram** to extend its functionality, accessing the safer `KeychainStorage` and encrypted `Endpoint`s (e.g. `Endpoint.Friendship.follow`, `Endpoint.Friendship.unfollow`).
    </p>
</details>

<p />

## Usage
Check out our [Examples](Examples) or visit the (_auto-generated_) documentation for [**Swiftagram**](https://sbertix.github.io/Swiftagram/Swiftagram) and [**SwiftagramCrypto**](https://sbertix.github.io/Swiftagram/SwiftagramCrypto) to learn about use cases.   

### Authentication
Authentication is provided through conformance to the `Authenticator` protocol, which, on success, returns a `Secret` containing all the cookies needed to sign an `Endpoint`'s request.

The library comes with two concrete implementations.

#### WebView-based

`Authenticator.Group.Visual` is a visual based `Authenticator`, relying on a `WKWebView` in order to log in the user.
As it's based on `WebKit`, it's only available for iOS 11 (and above) and macOS 10.13 (and above).

<details><summary><strong>Example</strong></summary>
    <p>

```swift
import UIKit

import Swiftagram

/// A `class` defining a view controller capable of displaying the authentication web view.
class LoginViewController: UIViewController {
    /// The completion handler.
    var completion: ((Secret) -> Void)? {
        didSet {
            guard oldValue == nil, let completion = completion else { return }
            // Authenticate.
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                // We're using `Authentication.keyhcain`, being encrypted,
                // but you can rely on different ones.
                Authenticator.keychain
                    .visual(filling: self.view)
                    .authenticate()
                    .sink(receiveCompletion: { _ in }, receiveValue: completion)
                    .store(in: &self.bin)
            }
        }
    }

    /// The dispose bag.
    private var bin: Set<AnyCancellable> = []
}
```

And then you can use it simply by initiating it and assining a `completion` handler.

```swift
let controller = LoginViewController()
controller.completion = { _ in /* do something */ }
// Present/push the controller.
```

</p></details>

#### Basic

`Authenticator.Group.Basic` is a code based `Authenticator`, supporting 2FA, defined in **SwiftagramCrypto**: all you need is a _username_ and _password_ and you're ready to go.

<details><summary><strong>Example</strong></summary>
    <p>

```swift
import SwiftagramCrypto

/// A retained dispose bag.
/// **You need to retain this.**
private var bin: Set<AnyCancellable> = []

// We're using `Authentication.keyhcain`, being encrypted,
// but you can rely on different ones.
Authenticator.keychain
    .basic(username: /* username */,
           password: /* password */)
    .authenticate()
    .sink(receiveCompletion: {
            switch $0 {
            case .failure(let error):
                // Deal with two factor authentication.
                switch error {
                case Authenticator.Error.twoFactorChallenge(let challenge):
                    // Once you receive the challenge,
                    // ask the user for the 2FA code
                    // then just call:
                    // `challenge.code(/* the code */).authenticate()`
                    // and deal with the publisher.
                    break
                default:
                    break
                }
            default:
                break
            }
          }, 
          receiveValue: { _ in /* do something */ })
    .store(in: &self.bin)
}
```

</p></details>

### Caching
Caching of `Secret`s is provided through its conformacy to [**ComopsableStorage**](https://github.com/sbertix/ComposableRequest)'s `Storable` protocol.  

The library comes with several concrete implementations of `Storage`.  
- `TransientStorage` should be used when no caching is necessary, and it's what `Authenticator`s default to when no `Storage` is provided.  
- `UserDefaultsStorage` allows for faster, out-of-the-box, testing, although it's not recommended for production as private cookies are not encrypted.  
- `KeychainStorage`, part of **ComposableRequestCrypto**, (**preferred**) stores them safely in the user's keychain.  

### Request
> How can I bypass Instagram "spam" filter, and make them believe I'm not actually a bot?

In older versions of **Swiftagram** we let the user set a delay between the firing of a request, and its actual dispatch. 
This would eventually just slow down implementations, doing close to nothing to prevent misuse. 

Starting with `5.0`, we're now directly exposing `URLSession`s to final users, so you can build your own implementation.  

**Swiftagram** defines a `static` `URLSession` (`URLSession.instagram`) fetching one resource at a time. Relying on this is the preferred way to deal with Instagram "spam" filter.

```swift
// A valid secret.
let secret: Secret = /* the authentication response */
// A **retained** collection of cancellables.
var bin: Set<AnyCancellable> = []

// We're using a random endpoint to demonstrate 
// how `URLSession` is exposed in code. 
Endpoint.user(secret.identifier)
    .unlock(with: secret)
    .session(.instagram)    // `URLSession.instagram` 
    .sink(receiveCompletion: { _ in }, receiveValue: { print($0) })
    .store(in: &bin)
```

> What about cancelling an ongoing request?

Once you have a stream `Cancellable`, just call `cancel` on it or empty `bin`.

```swift
// A valid secret.
let secret: Secret = /* the authentication response */
// A **retained** collection of cancellables.
var bin: Set<AnyCancellable> = []

// We're using a random endpoint to demonstrate 
// how `Deferrable` is exposed in code. 
Endpoint.user(secret.identifier)
    .unlock(with: secret)
    .session(.instagram) 
    .sink(receiveCompletion: { _ in }, receiveValue: { print($0) })
    .store(in: &bin)
    
// Cancel it.
bin.removeAll()
```

> How do I deal with pagination and pagination offsets? 

Easy. 
Assuming you're fetching a resource that can actually be paginated… 

```swift
// A valid secret.
let secret: Secret = /* the authentication response */
// A **retained** collection of cancellables.
var bin: Set<AnyCancellable> = []

// We're using a random endpoint to demonstrate 
// how `PagerProvider` is exposed in code. 
Endpoint.user(secret.identifier)
    .posts
    .unlock(with: secret)
    .session(.instagram)
    .pages(.max)    // Exhaust all with `.max`
                    // or pass any `Int` to limit
                    // pages.
    .sink(receiveCompletion: { _ in }, receiveValue: { print($0) })
    .store(in: &bin)
```

`PagerProvider` also supports an `offset`, i.e. the value passed to its first iteration, and a `rank` (token) in same cases, both as optional parameters in the `pages(_:offset:)`/`pages(_:offset:rank:)` method above.  

<p />

## Special thanks

> _Massive thanks to anyone contributing to [TheM4hd1/SwiftyInsta](https://github.com/TheM4hd1/SwiftyInsta), [dilame/instagram-private-api](https://github.com/dilame/instagram-private-api) and [ping/instagram_private_api](https://github.com/ping/instagram_private_api), for the inspiration and the invaluable service to the open source community, without which there would likely be no **Swiftagram** today._
