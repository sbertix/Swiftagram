//
//  PaginatableModel.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 27/08/21.
//

import Foundation

import Requests

/// A `protocol` defining paginatable models.
public protocol PaginatableModel {
    /// The associated offset type.
    associatedtype Offset

    /// Compute next offset.
    var offset: Pages<Offset>.Instruction { get }
}

/// A `protocol` defining a string paginatable model.
public protocol MaxIdPaginatableModel: PaginatableModel where Offset == String? {
    /// The next max identifier.
    var nextMaxId: String? { get }
}

public extension MaxIdPaginatableModel {
    /// Compute next offset.
    var offset: Pages<Offset>.Instruction {
        nextMaxId.flatMap(Pages.Instruction.offset) ?? .stop
    }
}

public extension MaxIdPaginatableModel where Self: Wrappable {
    /// The next max identifier.
    var nextMaxId: String? {
        wrapped.nextMaxId.string(converting: true)
    }
}

// swiftlint:disable trailing_closure
public extension Receivables.Pager where Success: PaginatableModel {
    /// Init.
    ///
    /// - parameters:
    ///     - input: A concrete instance of `PagerInput`.
    ///     - generator: A valid child generator.
    init<P: PagerInput>(_ input: P, generator: @escaping (Offset) -> Child) where P.Offset == Offset, Success.Offset == Offset {
        self.init(offset: input.offset,
                  count: input.count,
                  generator: generator,
                  nextOffset: { $0.offset })
    }
}

public extension Receivables.Pager where Success == Wrapper, Offset == String? {
    /// Init.
    ///
    /// - parameters:
    ///     - input: A concrete instance of `PagerInput`.
    ///     - generator: A valid child generator.
    init<P: PagerInput>(_ input: P, generator: @escaping (Offset) -> Child) where P.Offset == Offset {
        self.init(offset: input.offset,
                  count: input.count,
                  generator: generator,
                  nextOffset: { $0.nextMaxId.string(converting: true).flatMap(Pages.Instruction.offset) ?? .stop })
    }
}
// swiftlint:enable trailing_closure
