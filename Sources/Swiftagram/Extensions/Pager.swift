//
//  Pager.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 06/02/21.
//

import Foundation

import ComposableRequest

public extension Pager where Generator == Future<Page<Wrapper, String?>, Error> {
    /// Init.
    ///
    /// - parameters:
    ///     - pages: A valid `Int`.
    ///     - offset: An optional `String`.
    ///     - transformer: A valid mapper.
    ///     - generator: A valid `Generator`.
    init(_ input: PagerProviderInput<RankedPageReference<String, String>?>,
         transformer: @escaping (Wrapper) -> String? = { $0.nextMaxId.string() },
         generator: @escaping (_ output: Wrapper?, _ next: String?, _ offset: Int) -> Future<Wrapper, Error>?) {
        self.init(pages: input.pages) { output, index -> Future<Page<Wrapper, String?>, Error>? in
            guard output == nil || output?.bookmark != nil else { return nil }
            return generator(output?.content, output == nil ? input.offset?.offset : output?.bookmark, index)
                .flatMap { $0.map { Page(content: $0, bookmark: transformer($0)) }}
        }
    }

    /// Init.
    ///
    /// - parameters:
    ///     - pages: A valid `Int`.
    ///     - offset: An optional `String`.
    ///     - transformer: A valid mapper.
    ///     - generator: A valid `Generator`.
    init(_ input: PagerProviderInput<String?>,
         transformer: @escaping (Wrapper) -> String? = { $0.nextMaxId.string() },
         generator: @escaping (_ output: Wrapper?, _ next: String?, _ offset: Int) -> Future<Wrapper, Error>?) {
        self.init(pages: input.pages) { output, index -> Future<Page<Wrapper, String?>, Error>? in
            guard output == nil || output?.bookmark != nil else { return nil }
            return generator(output?.content, output == nil ? input.offset : output?.bookmark, index)
                .flatMap { $0.map { Page(content: $0, bookmark: transformer($0)) }}
        }
    }
}

public extension Pager where Output: PaginatedType {
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
