//
//  Response.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/02/2019.
//  Inspired by https://github.com/saoudrizwan/DynamicJSON
//

import Foundation

@dynamicMemberLookup
/// An `enum` holding reference to possible `JSON` objects.
public enum Response: Equatable {
    /// An `Array`.
    case array([Response])
    /// A `Bool`, `Double` or `Int`.
    case number(NSNumber)
    /// A `Dictionary`.
    case dictionary([String: Response])
    /// A `String`.
    case string(String)
    /// An empty value.
    case none

    // MARK: Lifecycle
    init(data: Data,
         options: JSONSerialization.ReadingOptions = .allowFragments) throws {
        self = try Response(JSONSerialization.jsonObject(with: data, options: options))
    }

    public init(_ object: Any) {
        switch object {
        // match `Array`.
        case let array as [Any]:
            self = .array(array.map { Response($0) })
        // match `Bool`, `Double` or `Int`.
        case let number as NSNumber:
            self = .number(number)
        // match `Data`.
        case let data as Data:
            self = (try? Response(data: data)) ?? .none
        // match `Dictionary`.
        case let dictionary as [String: Any]:
            self = .dictionary(Dictionary(uniqueKeysWithValues: dictionary.map {
                ($0.key.camelCased, Response($0.value))
            }))
        // match `String`.
        case let string as String:
            self = .string(string)
        // anything else.
        default:
            self = .none
        }
    }

    func data(options: JSONSerialization.WritingOptions = []) throws -> Data {
        return try JSONSerialization.data(withJSONObject: any, options: options)
    }

    // MARK: Accessories
    /// Returned a beautified description.
    public var beautifiedDescription: String {
        let data: Data
        if #available(iOS 11, macOS 10.13, tvOS 11, watchOS 4, *) {
          data = (try? self.data(options: [.prettyPrinted, .sortedKeys])) ?? Data()
        } else {
          data = (try? self.data(options: [.prettyPrinted])) ?? Data()
        }
        return String(data: data, encoding: .utf8) ?? ""
    }

    /// `Any`.
    public var any: Any {
        switch self {
        case .array(let array): return array.map { $0.any }
        case .dictionary(let dictionary): return dictionary.mapValues { $0.any }
        case .number(let number): return number
        case .string(let string): return string
        case .none: return NSNull()
        }
    }

    /// `[DynamicResponse]` if `.array` or `nil`.
    public var array: [Response]? {
        guard case let .array(array) = self else { return nil }
        return array
    }

    /// `Bool` if  `.bool`, `.int`, `.string` or `nil`.
    public var bool: Bool? {
        switch self {
        case .number(let number): return number.boolValue
        case .string(let string) where ["yes", "y", "true", "t", "1"].contains(string.lowercased()):
            return true
        case .string(let string) where ["no", "n", "false", "f", "0"].contains(string.lowercased()):
            return false
        default: return nil
        }
    }

    /// `[String: DynamicResponse]` if `.dictionary` or `nil`.
    public var dictionary: [String: Response]? {
        guard case let .dictionary(dictionary) = self else { return nil }
        return dictionary
    }

    /// `Double` if `.double`, `.int` or `nil`.
    public var double: Double? {
        switch self {
        case .number(let number): return number.doubleValue
        default: return nil
        }
    }

    /// `Int` if `.int` or `nil`.
    public var int: Int? {
        switch self {
        case .number(let number): return number.intValue
        default: return nil
        }
    }

    /// `String` if `.string`, `.url` or `nil`.
    public var string: String? {
        switch self {
        case .string(let string): return string
        case .number(let number): return String(number.intValue)
        default: return nil
        }
    }

    /// `URL` if `.url` or `nil`.
    public var url: URL? {
        switch self {
        case .string(let string): return URL(string: string)
        case .dictionary(let dictionary): return dictionary["url"]?.url
        default: return nil
        }
    }

    // MARK: Subscripts
    /// Interrogate `.dictionary`.
    public subscript(dynamicMember member: String) -> Response {
        guard case let .dictionary(dictionary) = self else { return .none }
        return dictionary[member] ?? .none
    }

    /// Access `index`-th item in `.array`.
    public subscript(index: Int) -> Response {
        guard case let .array(array) = self, (0..<array.count).contains(index) else { return .none }
        return array[index]
    }

    /// Interrogate `.dictionary`.
    public subscript(key: String) -> Response {
        guard case let .dictionary(dictionary) = self else { return .none }
        return dictionary[key] ?? .none
    }
}
