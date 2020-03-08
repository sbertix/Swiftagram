# Swiftagram
![Push](https://github.com/sbertix/Swiftagram/workflows/Push%20(master)/badge.svg)
![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/sbertix/Swiftagram)
[![GitHub](https://img.shields.io/github/license/sbertix/Swiftagram)](LICENSE)
[![PayPal](https://img.shields.io/badge/support-PayPal-blue?style=flat&logo=paypal)](https://www.paypal.me/sbertix)

**Instagram** offers two kinds of APIs to developers. The **Instagram Basic Display API** (extremely limited in functionality), and the **Instagram Graph API** for _Professional_, i.e. _Business_ and _Creator_, accounts only.

However, Instagram apps rely on a third type of API, the so-called Private API or Unofficial API, and **Swiftagram** is an iOS, macOS, tvOS, watchOS and Linux client for them, written entirely in Swift. You can try and create a better Instagram experience for your users, or write bots for automating different tasks.

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

## Usage
Visit the [Wiki](https://github.com/sbertix/Swiftagram/wiki) to learn about use cases.  

#### Authentication
Authentication is provided through conformance to the [`Authenticator`](https://github.com/sbertix/Swiftagram/wiki/Authenticator) protocol.  

The library comes with a concrete implementation allowing access with _username_ and _password_, named [`BasicAuthenticator`](https://github.com/sbertix/Swiftagram/wiki/BasicAuthenticator).  
Future versions are expected to also provide a web view based `Authenticator`.

#### Caching
Caching of [`Authentication.Response`](https://github.com/sbertix/Swiftagram/wiki/Authentication_Response)s is provided through conformance to the [`Storage`](https://github.com/sbertix/Swiftagram/wiki/Storage) protocol.  

The library comes with several concrete implementations.  
- [`TransientStorage`](https://github.com/sbertix/Swiftagram/wiki/TransientStorage) should be used when no caching is necessary.  
- [`UserDefaultsStorage`](https://github.com/sbertix/Swiftagram/wiki/UserDefaultsStorage) allows for faster, out-of-the-box, testing, although it's not recommended for production as private cookies are not encoded.  
- [`KeychainStorage`](https://github.com/sbertix/Swiftagram/wiki/KeychainStorage) (**preferred**) stores them safely in the user's keychain.  


## Contributions
Pull requests and issues are more than welcome.
