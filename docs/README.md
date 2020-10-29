# Swiftagram
[![Swift](https://img.shields.io/badge/Swift-5.1-%23DE5C43?style=flat&logo=swift)](https://swift.org)
[![codecov](https://codecov.io/gh/sbertix/Swiftagram/branch/main/graph/badge.svg)](https://codecov.io/gh/sbertix/Swiftagram)
![iOS](https://img.shields.io/badge/iOS-9.0-ff69b4)
![macOS](https://img.shields.io/badge/macOS-10.12-ff69b4)
![tvOS](https://img.shields.io/badge/tvOS-11.0-ff69b4)
![watchOS](https://img.shields.io/badge/watchOS-3.0-ff69b4)
[![Telegram](https://img.shields.io/badge/Telegram-Swiftagram-blue?style=flat&logo=telegram)](https://t.me/swiftagram)

**Swiftagram** is a wrapper for [**Instagram**](https://instagram.com) Private API, written entirely in modern **Swift**. 

**Instagram**'s official APIs, both the [*Instagram Basic Display API*](https://developers.facebook.com/docs/instagram-basic-display-api) and the [*Instagram Graph API*] — available for *Creator* and *Business* accounts alone, either lack support for the most mundane of features or limit their availability to a not large enough subset of profiles. 

In order to bypass these limitations, **Swiftagram** relies on the API used internally by the Android and iOS official **Instagram** apps, requiring no _API token_, and allowing to reproduce virtually any action a user can take. 
Please just bear in mind, as they're not authorized for external use, you're using them at your own risk. 
<br />

> What's **SwiftagramCrypto**?

Relying on encryption usually requires specific disclosure, e.g. on submission to the **App Store**. 

Despite **Swiftagram** cannot be considered **App Store** safe, we still value separating everything depending on encryption into its owen target library, we call **SwiftagramCrypto**. 
Keep in mind features like `BasicAuthenticator`, a non-visual `Authenticator`, or `KeychainStorage`, the safe and preferred way to store `Secret`s, or even the ability to post on your feed and upload stories are **SwiftagramCrypto** only. 

Please check out the _docs_ to find out more. 

## Status
![push](https://github.com/sbertix/Swiftagram/workflows/push/badge.svg)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/sbertix/Swiftagram)

You can find all changelogs directly under every [release](https://github.com/sbertix/Swiftagram/releases), and if you care to be notified about future ones, don't forget to subscribe to our [Telegram channel](https://t.me/Swiftagram). 

[![Stargazers over time](https://starchart.cc/sbertix/Swiftagram.svg)](https://starchart.cc/sbertix/Swiftagram)

> What's next?

[Milestones](https://github.com/sbertix/Swiftagram/milestones), [issues](https://github.com/sbertix/Swiftagram/issues), as well as the [_WIP dashboard_](https://github.com/sbertix/Swiftagram/projects/1), are the best way to keep updated with active developement. 

Feel free to contribute by sending a [pull request](https://github.com/sbertix/Swiftagram/pulls). 
Just remember to refer to our [guidelines](CONTRIBUTING.md) and [Code of Conduct](CODE_OF_CONDUCT.md) beforehand.

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

- **SwiftagramCrypto**, depending on **ComposableRequestCrypto** and a fork of [**SwCrypt**](https://github.com/sbertix/SwCrypt), can be imported together with **Swiftagram** to extend its functionality, accessing the safer `KeychainStorage` and encrypted `Endpoint`s (e.g. `Endpoint.Friendship.follow`, `Endpoint.Friendship.unfollow`).
    </p>
</details>

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

import ComposableRequest
import ComposableRequestCrypto
import Swiftagram

/// A `class` defining a `UIViewController` displaying a `WKWebView` used for authentication.
final class LoginViewController: UIViewController {
    /// Any `ComposableRequest.Storage` used to cache `Secret`s.
    /// We're using `KeychainStorage` as it's the safest option.
    let storage = KeychainStorage()
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
import ComposableRequest
import ComposableRequestCrypto
import Swiftagram
import SwiftagramCrypto

/// Any `ComposableRequest.Storage` used to cache `Secret`s.
/// We're using `KeychainStorage` as it's the safest option.
let storage = KeychainStorage()
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
Caching of `Secret`s is provided through conformance to the `Storage` protocol in [**ComposableRequest**](https://github.com/sbertix/ComposableRequest).  

The library comes with several concrete implementations.  
- `TransientStorage` should be used when no caching is necessary, and it's what `Authenticator`s default to when no `Storage` is provided.  
- `UserDefaultsStorage` allows for faster, out-of-the-box, testing, although it's not recommended for production as private cookies are not encoded.  
- `KeychainStorage`, part of **ComposableRequestCrypto**, (**preferred**) stores them safely in the user's keychain.  

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

## Special thanks

> _Massive thanks to anyone contributing to [TheM4hd1/SwiftyInsta](https://github.com/TheM4hd1/SwiftyInsta), [dilame/instagram-private-api](https://github.com/dilame/instagram-private-api) and [ping/instagram_private_api](https://github.com/ping/instagram_private_api), for the inspiration and the invaluable service to the open source community, without which there would likely be no **Swiftagram** today._
