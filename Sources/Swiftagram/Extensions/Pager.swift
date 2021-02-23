//
//  Pager.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 06/02/21.
//

import Foundation

import ComposableRequest

public extension Projectables.Pager where Generator == AnyProjectable<Page<Wrapper, String?>, Error> {
    /// Init.
    ///
    /// - parameters:
    ///     - pages: A valid `Int`.
    ///     - offset: An optional `String`.
    ///     - transformer: A valid mapper.
    ///     - generator: A valid `Generator`.
    init<P: Projectable>(_ input: PagerProviderInput<RankedPageReference<String, String>?>,
                         transformer: @escaping (Wrapper) -> String? = { $0.nextMaxId.string() },
                         generator: @escaping (_ output: Wrapper?, _ next: String?, _ offset: Int) -> P?)
    where P.Output == Wrapper, P.Failure == Error {
        self.init(pages: input.pages) { output, index -> AnyProjectable<Page<Wrapper, String?>, Error>? in
            guard output == nil || output?.bookmark != nil else { return nil }
            return generator(output?.content, output == nil ? input.offset?.offset : output?.bookmark, index)
                .flatMap { $0.map { Page(content: $0, bookmark: transformer($0)) }}?
                .eraseToAnyProjectable()
        }
    }

    /// Init.
    ///
    /// - parameters:
    ///     - pages: A valid `Int`.
    ///     - offset: An optional `String`.
    ///     - transformer: A valid mapper.
    ///     - generator: A valid `Generator`.
    init<P: Projectable>(_ input: PagerProviderInput<String?>,
                         transformer: @escaping (Wrapper) -> String? = { $0.nextMaxId.string() },
                         generator: @escaping (_ output: Wrapper?, _ next: String?, _ offset: Int) -> P?)
    where P.Output == Wrapper, P.Failure == Error {
        self.init(pages: input.pages) { output, index -> AnyProjectable<Page<Wrapper, String?>, Error>? in
            guard output == nil || output?.bookmark != nil else { return nil }
            return generator(output?.content, output == nil ? input.offset : output?.bookmark, index)
                .flatMap { $0.map { Page(content: $0, bookmark: transformer($0)) }}?
                .eraseToAnyProjectable()
        }
    }
}

public extension Projectables.Pager where Output: PaginatedType {
    /// Init.
    ///
    /// - parameters:
    ///     - input: A valid `PagerProviderInput`.
    ///     - generator: A valid generator.
    init(_ input: PagerProviderInput<RankedPageReference<String, String>?>,
         generator: @escaping (_ output: Output?, _ next: String?, _ offset: Int) -> Generator?) {
        self.init(pages: input.pages) { output, index in
            let next = output?.bookmark.next
            guard output == nil || next != nil else { return nil }
            return generator(output, output == nil ? input.offset?.offset : next, index)
        }
    }

    /// Init.
    ///
    /// - parameters:
    ///     - input: A valid `PagerProviderInput`.
    ///     - generator: A valid generator.
    init(_ input: PagerProviderInput<String?>,
         generator: @escaping (_ output: Output?, _ next: String?, _ offset: Int) -> Generator?) {
        self.init(pages: input.pages) { output, index in
            let next = output?.bookmark.next
            guard output == nil || next != nil else { return nil }
            return generator(output, output == nil ? input.offset : next, index)
        }
    }
}
