//
//  Section.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 19/04/21.
//

import Foundation

/// A `struct` defining a valid tag/location section.
public struct Section: Wrapped {
    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// Media in the response.
    public var items: [Media]? {
        self["layoutContent"]
            .fillItems
            .array()?
            .compactMap { $0.media.optional().flatMap(Media.init) }
        ?? self["layoutContent"]
            .medias
            .array()?
            .compactMap { $0.media.optional().flatMap(Media.init) }
    }

    /// Init.
    /// - parameter wrapper: A valid `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        self.wrapper = wrapper
    }
}

public extension Section {
    /// A `struct` defining a valid posts offset.
    struct Page: Hashable {
        /// Current max identifier.
        public let identifier: String
        /// Current page.
        public let page: Int?
        /// Current media identifiers.
        public let mediaIdentifiers: [String]

        /// Init.
        ///
        /// - parameters:
        ///     - identifier: A valid `String`.
        ///     - page: An optional `Int`.
        ///     - mediaIdentifiers: An array of `String`s.
        /// - note: You should not build this directly.
        public init(identifier: String,
                    page: Int?,
                    mediaIdentifiers: [String]) {
            self.identifier = identifier
            self.page = page
            self.mediaIdentifiers = mediaIdentifiers
        }
    }

    /// A `struct` defining a collection of `Section`s.
    struct Collection: Specialized, PaginatableModel {
        /// The underlying `Response`.
        public var wrapper: () -> Wrapper

        /// All available sections.
        public var sections: [Section]? {
            self["sections"].array()?.compactMap(Section.init)
        }

        /// The offset.
        public var offset: Pages<Page?>.Instruction {
            guard self["moreAvailable"].bool() ?? false,
                  let identifier = self["nextMaxId"].string(converting: true) else {
              return .stop
            }
            // Parse all data.
            let page = self["nextPage"].int()
            let mediaIdentifiers = self["nextMediaIds"].array()?.compactMap { $0.string(converting: true) } ?? []
            return .offset(.init(identifier: identifier, page: page, mediaIdentifiers: mediaIdentifiers))
        }

        /// Init.
        /// - parameter wrapper: A valid `Wrapper`.
        public init(wrapper: @escaping () -> Wrapper) {
            self.wrapper = wrapper
        }
    }
}

public extension Section.Collection {
    /// The associated offset.
    typealias Offset = Section.Page?
}
