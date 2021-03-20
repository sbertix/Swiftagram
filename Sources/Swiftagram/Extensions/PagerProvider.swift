//
//  PagerProvider.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 06/02/21.
//

import Foundation

public extension PagerProvider where Offset: RankedPage {
    /// Authenticate.
    ///
    /// - parameters:
    ///     - pages: A valid `Int`.
    ///     - offset: An optional `Offset`.
    ///     - rank: An optional `Rank`.
    /// - returns: Some `Content`.
    func pages(_ pages: Int, offset: Offset.Offset?, rank: Offset.Rank?) -> Output {
        self.pages(pages, offset: .init(offset: offset, rank: rank))
    }

    /// Authenticate.
    ///
    /// - parameters:
    ///     - pages: A valid `Int`.
    ///     - offset: An optional `Output`.
    /// - returns: Some `Content`.
    func pages(_ pages: Int, offset: Offset.Offset?) -> Output {
        self.pages(pages, offset: offset, rank: nil)
    }

    /// Authenticate.
    ///
    /// - parameters:
    ///     - pages: A valid `Int`.
    ///     - rank: An optional `Rank`.
    /// - returns: Some `Content`.
    func pages(_ pages: Int, rank: Offset.Rank?) -> Output {
        self.pages(pages, offset: nil, rank: rank)
    }
}

/// A `protocol` defining a ranked reference instance.
public protocol RankedPage {
    /// The associated offset type.
    associatedtype Offset
    /// The associated rank type.
    associatedtype Rank

    /// Init.
    ///
    /// - parameters:
    ///     - offset: An optional `Offset`.
    ///     - rank: An optional `Rank`.
    init(offset: Offset?, rank: Rank?)

    /// The actual offset.
    var offset: Offset? { get }
    /// The rank token.
    var rank: Rank? { get }
}

/// A `struct` defining a pagination parameters allowing for a custom rank token.
public struct RankedPageReference<Offset, Rank>: RankedPage {
    /// The actual offset.
    public let offset: Offset?
    /// The rank token.
    public let rank: Rank?

    /// Init.
    ///
    /// - parameters:
    ///     - offset: An optional `Offset`.
    ///     - rank: An optional `Rank`.
    public init(offset: Offset?, rank: Rank?) {
        self.offset = offset
        self.rank = rank
    }
}

extension RankedPageReference: Equatable where Offset: Equatable {
    /// Check equality.
    ///
    /// - parameters:
    ///     - lhs: A valid `RankedPageReference`.
    ///     - rhs: A valid `RankedPageReference`.
    /// - returns: A valid `Bool`.
    public static func ==(lhs: RankedPageReference, rhs: RankedPageReference) -> Bool {
        lhs.offset == rhs.offset
    }
}
