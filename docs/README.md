<br />
<img alt="Header" src="https://github.com/sbertix/Swiftagram/blob/main/Resources/header.png" height="72" />
<br />

[![Swift](https://img.shields.io/badge/Swift-5.1-%23DE5C43?style=flat&logo=swift)](https://swift.org)
[![codecov](https://codecov.io/gh/sbertix/Swiftagram/branch/main/graph/badge.svg)](https://codecov.io/gh/sbertix/Swiftagram)
[![Telegram](https://img.shields.io/badge/Telegram-Swiftagram-blue?style=flat&logo=telegram)](https://t.me/swiftagram)
<br />
![iOS](https://img.shields.io/badge/iOS-9.0-DD5D43)
![macOS](https://img.shields.io/badge/macOS-10.12-DD5D43)
![tvOS](https://img.shields.io/badge/tvOS-11.0-DD5D43)
![watchOS](https://img.shields.io/badge/watchOS-3.0-DD5D43)

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

- **Swiftagram** depends on [**ComposableRequest**](https://github.com/sbertix/ComposableRequest), an HTTP client originally integrated in **Swiftagram**.\
It supports [`Combine`](https://developer.apple.com/documentation/combine) `Publisher`s and caching `Secret`s, through **ComposableStorage**, out-of-the-box.

- **SwiftagramCrypto**, depending on [**Swiftchain**](https//github.com/sbertix/Swiftchain) and a fork of [**SwCrypt**](https://github.com/sbertix/SwCrypt), can be imported together with **Swiftagram** to extend its functionality, accessing the safer `KeychainStorage` and encrypted `Endpoint`s (e.g. `Endpoint.Friendship.follow`, `Endpoint.Friendship.unfollow`).
    </p>
</details>

<p />

## Usage
Check out our [Examples](Examples) or visit the (_auto-generated_) [Documentation](https://sbertix.github.io/Swiftagram) to learn about use cases.  

### Authentication
Authentication is provided through conformance to the `Authenticator` protocol, which, on success, returns a `Secret` containing all the cookies needed to sign an `Endpoint`'s request.

The library comes with two concrete implementations.

#### WebViewAuthenticator

`WebViewAuthenticator` is a visual based `Authenticator`, relying on a `WKWebView` in order to log in the user.
As it's based on `WebKit`, it's only available for iOS 11 (and above) and macOS 10.13 (and above).

<details><summary><strong>Example</strong></summary>
    <p>

```swift
import UIKit
import WebKit

import ComposableStorage
import Swiftagram
import Swiftchain

/// A `class` defining a `UIViewController` displaying a `WKWebView` used for authentication.
final class LoginViewController: UIViewController {
    /// Any `ComposableRequest.Storage` used to cache `Secret`s.
    /// We're using `KeychainStorage` as it's the safest option.
    let storage = KeychainStorage<Secret>()
    /// A valid `Client`. We're relying on the `default` one.
    let client = Client.default

    /// The web view.
    var webView: WKWebView? {
        didSet {
            oldValue?.removeFromSuperview() // Just in case.
            guard let webView = webView else { return }
            webView.frame = view.bounds     // Fill the parent view.
            // You should also deal with layout constraints or similar here…
            view.addSubview(webView)        // Add it to the parent view.
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Authenticate using any `Storage` you want (`KeychainStorage` is used as an example).
        // `storage` can be omitted if you don't require `Secret`s caching.
        // `client` can be omitted and the default once will be used.
        WebViewAuthenticator(storage: storage,
                             client: client) { self.webView = $0 }
            .authenticate {
                switch $0 {
                    case .failure(let error): print(error.localizedDescription)
                    default: print("Login succesful.")
                }
            }
        }
    }
}
```

</p></details>

#### BasicAuthenticator

`BasicAuthenticator` is a code based `Authenticator`, supporting 2FA, defined in **SwiftagramCrypto**: all you need is a _username_ and _password_ and you're ready to go.

<details><summary><strong>Example</strong></summary>
    <p>

```swift
import ComposableStorage
import Swiftagram
import Swiftchain

/// Any `ComposableRequest.Storage` used to cache `Secret`s.
/// We're using `KeychainStorage` as it's the safest option.
let storage = KeychainStorage<Secret>()
/// A valid `Client`. We're relying on the `default` one.
let client = Client.default

/// Authenticate.
BasicAuthenticator(storage: storage,    // Optional. No storage will be used if omitted.
                   client: client,      // Optional. Default client will be used if omitted.
                   username: /* username */,
                   password: /* password */)
    .authenticate {
        switch $0 {
        case .failure(let error):
            // Please check out the docs to find out how to deal with 2FA.
            print(error.localizedDescription)
        default: print("Login successful.")
        }
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

Starting with `5.0`, we're now directly exposing `URLSession`s to final users, so you can build your own implementation. And through `Scheduler.Work`, in case you still want to mimic the old behavior, you can add back any delay you feel necessary (although it's not recommended at this point). 

**Swiftagram** defines a `static` `URLSession` (`URLSession.instagram`) fetching one resource at a time. Relying on this is the preferred way to deal with Instagram "spam" filter.

```swift
let secret: Secret = /* the authentication response */

// We're using a random endpoint to demonstrate 
// how `URLSession` is exposed in code. 
Endpoint.User.Summary(for: secret.identifier)
    .unlock(with: secret)
    .session(.instagram)    // `URLSession.instagram` 
    .observe { _ in }
```

> What about cancelling an ongoing request?

The new **ComposableRequest** `Observable`, on which all `Endpoint`s are built, is heavily based on standardized (deferred) `Future`s, which, by definition, do not allow for cancellation per se. 
That's why In **Swiftagram** `5.0`, you'll note a renwed approach to cancellation – and task management as a whole. Cancelling and resuming a request is now independent from the actual `Observable` stream, allowing for better notifications too (cancelled requests now trigger a descriptive `Error` instead of just vanishing in thin air, so you have a way to deal with it directly). 

All you need to do is link a `Token` with your `Endpoint` request.

```swift
let secret: Secret = /* the authentication response */

// The source for the `Token` used to control
// the request.
let source: Token.Source = .init()
// We're using a random endpoint to demonstrate 
// how `Token` is exposed in code. 
Endpoint.User.Summary(for: secret.identifier)
    .unlock(with: secret)
    .session(.instagram, controlledBy: source.token) 
    .observe { _ in }
```

Nothing will happen until you call `source.resume()`, and you can just as easily cancel the request with `source.cancel()`. 
If you still want to be able to deal with cancellation, without having to explicitly resume the request, you can rely on a custom `Token.Source`.

```swift
let source: Token.Source = .immediate

// Which is equivalent to…

let equivalentSource: Token.Source = .init()
equivalentSource.resume()
```

> How do I deal with pagination and pagination offsets? 

Easy. 
Assuming you're fetching a resource that can actually be paginated… 

```swift
let secret = /* the authentication response */

// We're using a random endpoint to demonstrate 
// how `PagerProvider` is exposed in code. 
Endpoint.Media.owned(by: secret.identifier)
    .unlock(with: secret)
    .session(.instagram)
    .pages(.max)    // Exhaust all with `.max`
                    // or pass any `Int` to limit
                    // pages.
    .observe { _ in }
```

`PagerProvider` also supports an `offset`, i.e. the value passed to its first iteration, and a `rank` (token) in same cases, both as optional parameters in the `pages(_:offset:)`/`pages(_:offset:rank:)` method above.  

### Combine

`Observable` expose a `publish` method by default. 

```swift
var bin: Set<AnyCancellable> = []
let secret = /* the authentication response */

// We're using a random endpoint to demonstrate 
// how `Combine` is exposed in code. 
Endpoint.User.Summary(for: secret.identifier)
    .unlock(with: secret)
    .session(.instagram) 
    .publish()
    .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    .store(in: &bin)
```

If you're relying on `Token`s, you can also link them to your `Publisher`, so you don't have to deal with it yourself. 

```swift
let secret: Secret = /* the authentication response */

// The source for the `Token` used to control
// the request.
let source: Token.Source = .init()
// We're using a random endpoint to demonstrate 
// how `Token` is exposed in code. 
Endpoint.User.Summary(for: secret.identifier)
    .unlock(with: secret)
    .session(.instagram, controlledBy: source.token) 
    .publish(handling: source.token)    // There's also a method 
                                        // accepting a collection of
                                        // `Token`s. 
    .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    .store(in: &bin)
```

<p />

## Special thanks

> _Massive thanks to anyone contributing to [TheM4hd1/SwiftyInsta](https://github.com/TheM4hd1/SwiftyInsta), [dilame/instagram-private-api](https://github.com/dilame/instagram-private-api) and [ping/instagram_private_api](https://github.com/ping/instagram_private_api), for the inspiration and the invaluable service to the open source community, without which there would likely be no **Swiftagram** today._
