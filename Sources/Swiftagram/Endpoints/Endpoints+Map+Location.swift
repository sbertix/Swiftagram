//
//  Endpoints+Map+Location.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 05/12/22.
//

import Foundation

/// An `enum` listing available posts
/// sorting at a specific location.
public enum MapPosts: String {
    /// Most recent first.
    case recent = "recent"
    /// Most popular first.
    case popular = "ranked"
}

/// A `struct` defining the page reference
/// for posts endpoints.
///
/// `init` is hidden outside this scope as
/// this is not intended to be created directly.
public struct MapNext: Identifiable {
    /// The max identiifer.
    public let id: String
    /// The offset.
    public let offset: Int
    /// Page media identifiers.
    public let posts: [String]
}

public extension Endpoints.Map {
    /// A `struct` defining an instance
    /// holding reference to a specific location.
    struct Location: Identifiable {
        /// The location identifier.
        public let id: String

        /// Init.
        ///
        /// - parameter id: The location identifier.
        public init(id: ID) {
            self.id = id
        }
    }
}

public extension Endpoints.Map.Location {
    /// Fetch more info for the location.
    var summary: Endpoint.Single<AnyDecodable> {
        .init { secret in
            Single {
                Path("https://i.instagram.com/api/v1/locations/\(id)/info/")
                Headers() // Default headers.
                Headers(secret.header)
                Response(AnyDecodable.self) // Location.Unit
            }.eraseToAnySingleEndpoint()
        }
    }

    /// Fetch recent posts at the location.
    var posts: Endpoint.Loop<MapNext?, AnyDecodable> {
        posts(.recent)
    }

    /// Fetch recent stories at the location.
    var stories: Endpoint.Single<AnyDecodable> {
        .init { secret in
            Single {
                Path("https://i.instagram.com/api/v1/locations/\(id)/story/")
                Headers() // Default headers.
                Headers(secret.header)
                Response(AnyDecodable.self) // TrayItem.Unit
            }.eraseToAnySingleEndpoint()
        }
    }

    /// Fetch posts at the location.
    ///
    /// - parameter posts: Some valid posts order.
    /// - returns: Some locked `LoopEndpoint`.
    func posts(_ posts: MapPosts) -> Endpoint.Loop<MapNext?, AnyDecodable> {
        .init { secret, offset in
            Loop<MapNext?, Single<AnyDecodable>>(startingAt: offset) {
                Path("https://i.instagram.com/api/v1/locations/\(id)/sections/")
                Headers() // Default headers.
                Headers(secret.header)
                Body(parameters: [
                    "max_id": $0?.id,
                    "tab": posts.rawValue,
                    "page": $0.flatMap { $0.offset <= 0 ? nil : "\($0.offset)" },
                    "next_media_ids": "[\($0?.posts.joined(separator: ",") ?? "")]",
                    "_csrftoken": secret["csrftoken"],
                    "_uuid": secret.client.device.identifier.uuidString,
                    "session_id": secret["sessionid"]
                ])
                Response(AnyDecodable.self) // Section.Collection
            } next: {
                guard $0.moreAvailable.bool ?? false,
                      let id = $0.nextMaxId.string,
                      let offset = $0.page.int,
                      let posts = $0.nextMediaIds.array?.compactMap(\.string) else {
                    return .break
                }
                return .advance(to: .init(id: id, offset: offset, posts: posts))
            }.eraseToAnyLoopEndpoint()
        }
    }
}
