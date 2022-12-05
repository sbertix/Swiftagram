////
////  Endpoint+Stories.swift
////  Swiftagram
////
////  Created by Stefano Bertagno on 08/04/21.
////
//
//import Foundation
//
//public extension Endpoint.Group {
//    /// A `class` defining stories-related endpoints.
//    final class Stories { }
//}
//
//public extension Endpoint {
//    /// A wrapper for stories-specific endpoints.
//    static var stories: Endpoint.Group.Stories { .init() }
//
//    /// An endpoint for loading specific endpoints.
//    ///
//    /// - parameter identifiers: A collection of `String`s.
//    /// - returns: A valid `Endpoint.Single`.
//    static func stories<C: Collection>(_ identifiers: C) -> Endpoint.Single<TrayItem.Dictionary> where C.Element == String {
//        users(identifiers).stories
//    }
//}
//
//public extension Endpoint.Group.Stories {
//    /// A list of archived stories.
//    var archived: Endpoint.Paginated<String?, TrayItem.Collection> {
//        Endpoint.archived.stories
//    }
//
//    /// The logged in user stories tray.
//    var recent: Endpoint.Single<TrayItem.Collection> {
//        Endpoint.recent.stories
//    }
//}
