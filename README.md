# Swiftagram
![Push (master)](https://github.com/sbertix/Swiftagram/workflows/Push%20(master)/badge.svg)
![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/sbertix/Swiftagram)
![Platforms](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20Linux-lightgrey?style=flat)
[![GitHub](https://img.shields.io/github/license/sbertix/Swiftagram)](LICENSE)
[![PayPal](https://img.shields.io/badge/support-PayPal-blue?style=flat&logo=paypal)](https://www.paypal.me/sbertix)

**Instagram** offers two kinds of APIs to developers. The **Instagram Basic Display API** (extremely limited in functionality), and the **Instagram Graph API** for _Professional_, i.e. _Business_ and _Creator_, accounts only.

However, Instagram apps rely on a third type of API, the so-called Private API or Unofficial API, and **Swiftagram** is an iOS, macOS, tvOS and watchOS client for them, written entirely in Swift. You can try and create a better Instagram experience for your users, or write bots for automating different tasks.

These Private API require no token or app registration but they're not authorized by Instagram for external use.  
Use this at your own risk.

## Status
#### **Swiftagram** is currently under development and more features are expected to be implemented everyday, which might result in breaking changes.

## Installation
#### Swift Package Manager (Xcode 11 and above)
1. Select `File`/`Swift Packages`/`Add Package Dependency…` from the menu.
1. Paste `https://github.com/sbertix/Swiftagram.git`.
1. Follow the steps.

**Swiftagram** depends on [KeychainSwift](https://github.com/evgenyneu/keychain-swift), and is compatible with Swift 5.0 or above.

## Authentication
Authentication is provided through conformance to the `Authenticator` protocol.  

The library comes with a concrete implementation allowing access with _username_ and _password_, named `BasicAuthenticator`.  
Future versions are expected to also provide a web view based `Authenticator`.

#### `BasicAuthenticator`
```swift
/// A strong reference to a 2FA object.
var twoFactor: TwoFactor? {
  didSet {
    guard let twoFactor = twoFactor else { return }
    // ask for the code and then pass it to `twoFactor.send`.
  }
}
/// A strong reference to a Checkpoint object.
var checkpoint: Checkpoint? {
  didSet {
    guard let checkpoint = checkpoint else { return }
    // ask for validation method then pass it to `checkpoint.request`, 
    // before sending the code to through `checkpoint.send`.
  }
}

/// Login.
BasicAuthenticator(storage: KeychainStorage(),  // any `Storage`.
                   username: /* the username */,
                   password: /* the password */)
  .authenticate {
    switch $0 {
    case .failure(let error): 
      switch error {
        case AuthenticatorError.checkpoint(let response): checkpoint = response
        case AuthenticatorError.twoFactor(let response): twoFactor = response
        default: print(error)
      }
    case .success: print("Logged in")
  }
```

## Caching
Caching of `Authentication.Response`s is provided through conformance to the `Storage` protocol.  

The library comes with several concrete implementations.  
- `TransientStorage` should be used when no caching is necessary.  
- `UserDefaultsStorage` allows for faster, out-of-the-box, testing, although it's not recommended for production as private cookies are not encoded.  
- `KeychainStorage` (preferred) stores them safely in the user's keychain.  


## Contributions
Pull requests and issues are more than welcome.
