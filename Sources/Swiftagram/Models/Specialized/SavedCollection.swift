//
//  SavedCollection.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 19/04/21.
//

import Foundation

/// A `struct` representing a `SavedCollection`.
public struct SavedCollection: Wrapped {
    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// The primary key.
    public var identifier: String! { self["collectionId"].string(converting: true) }

    /// The name.
    public var name: String! { self["collectionName"].string() }

    /// The collection type.
    ///
    /// - note: Only populated when fetching all collections.
    public var type: String? { self["collectionMediaType"].string() }

    /// The collection media count.
    ///
    /// - note: Only populated when fetching all collections.
    public var count: Int? { self["collectionMediaCount"].int() }

    /// The cover media items.
    ///
    /// - note: Only populated when fetching all collections.
    public var cover: [Media]? {
        self["coverMediaList"].array()?.compactMap(Media.init) ??
          self["coverMedia"].optional().flatMap{ [Media.init(wrapper: $0)] }
    }

    /// Media in the response.
    ///
    /// - note: Only populated when fetching a single collection.
     public var items: [Media]? { self["items"].array()?.compactMap { $0.media.optional().flatMap(Media.init) } }
    
    /// Init.
    /// - parameter wrapper: A valid `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        self.wrapper = wrapper
    }
}

public extension SavedCollection {
    /// A `struct` defining a collection of `SavedCollection`.
    struct Collection: Specialized, StringPaginatable {
        /// The underlying `Response`.
        public var wrapper: () -> Wrapper

        /// The collections.
        public var collections: [SavedCollection]? { self["items"].array()?.compactMap(SavedCollection.init) }

        /// Init.
        /// - parameter wrapper: A valid `Wrapper`.
        public init(wrapper: @escaping () -> Wrapper) {
            self.wrapper = wrapper
        }
    }

    /// A `struct` defining a single `SavedCollection` response.
    struct Unit: Specialized, StringPaginatable {
        /// The underlying `Response`.
        public var wrapper: () -> Wrapper

        /// The collection.
        public var collection: SavedCollection? { self["saveMediaResponse"].optional().flatMap(SavedCollection.init) }

        /// Media in the response.
        ///
        /// - note: Only populated when fetching posts and igtvs.
        public var items: [Media]? {
            self["items"].array()?.compactMap {
                $0.media.optional().flatMap(Media.init) ??
                  $0.optional().flatMap(Media.init)
            }
        }

        /// The offset.
        public var offset: String? {
            self["saveMediaResponse"].nextMaxId.string(converting: true) ?? self["nextMaxId"].string(converting: true) ??
                self["maxId"].string(converting: true)
        }

        /// Init.
        /// - parameter wrapper: A valid `Wrapper`.
        public init(wrapper: @escaping () -> Wrapper) {
            self.wrapper = wrapper
        }
    }
}
