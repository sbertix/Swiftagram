//
//  RequestCompletion.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

internal extension Request {
    /// An `enum` holding reference to possible completion types.
    enum Completion {
        /// Data.
        case data((Result<Requester.Task.Response<Data>, Swift.Error>) -> Void)
        /// String.
        case string((Result<Requester.Task.Response<String>, Swift.Error>) -> Void, encoding: String.Encoding)
        /// Dynamic response.
        case response((Result<Requester.Task.Response<Response>, Swift.Error>) -> Void)

        /// Parse `Data` into the `Completion` specific block input and then call it.
        internal func send(_ data: Result<Requester.Task.Response<Data>, Swift.Error>,
                           responseQueue: Requester.Queue) {
            switch self {
            case .data(let send): send(data)
            case .string(let send, let encoding):
                let response = data.map {
                    (data: String(data: $0.data, encoding: encoding) ?? "",
                     response: $0.response)
                }
                responseQueue.handle { send(response) }
            case .response(let send):
                let response = data.map {
                    (data: (try? Response(data: $0.data)) ?? .none,
                     response: $0.response)
                }
                responseQueue.handle { send(response) }
            }
        }
    }
}
