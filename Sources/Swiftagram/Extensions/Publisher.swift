//
//  Publisher.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 03/05/21.
//

import Foundation

import ComposableRequest

public extension Publisher where Output: Specialized {
    /// Consider endpoint `Error`s.
    ///
    /// - returns: Some `Publisher`.
    func replaceFailingWithError() -> AnyPublisher<Output, Error> {
        self.catch { Fail(error: $0 as Error) }
            .flatMap { output -> AnyPublisher<Output, Error> in
                switch output.error {
                case let error?: return Fail(error: error).eraseToAnyPublisher()
                case .none: return Just(output).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}
