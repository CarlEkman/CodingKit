//
// Copyright © 2019 Zoul. All rights reserved.
//

import Foundation

internal enum InitializationError: Error {
    case invalidAnyObject
    case invalidSerializedInput
}

extension JSON {

    /// Create a JSON value from anything.
    ///
    /// Argument has to be a valid JSON structure: A `Float`, `Int`, `String`,
    /// `Bool`, an `Array` of those types or a `Dictionary` of those types.
    ///
    /// You can also pass `nil` or `NSNull`, both will be treated as `.null`.
    public init(_ value: Any) throws {
        switch value {
        case _ as NSNull:
            self = .null
        case let opt as Optional<Any> where opt == nil:
            self = .null
        case let num as Float:
            self = .number(num)
        case let num as Int:
            self = .number(Float(num))
        case let str as String:
            self = .string(str)
        case let bool as Bool:
            self = .bool(bool)
        case let array as [Any]:
            self = .array(try array.map(JSON.init))
        case let dict as [String:Any]:
            self = .object(try dict.mapValues(JSON.init))
        default:
            throw InitializationError.invalidAnyObject
        }
    }

    public init(serialData: Data) throws {
        self = try JSONDecoder().decode(JSON.self, from: serialData)
    }

    public init(serialized string: String, encoding: String.Encoding = .utf8) throws {
        guard let data = string.data(using: encoding) else {
            throw InitializationError.invalidSerializedInput
        }
        self = try JSON(serialData: data)
    }

    /// Create a JSON value from anything. This is in essence an initializer,
    /// but should be used with caution as values may be silently failing when encoded.
    ///
    /// Arguments are expected to be a valid JSON structure: A `Float`, `Int`, `String`,
    /// `Bool`, an `Array` of those types or a `Dictionary` of those types.
    ///
    /// Values that cannot be interpreted as valid JSON will default to `.null`.
    public static func make(from unsafeValue: Any) -> JSON {
        switch unsafeValue {
        case _ as NSNull:
            return .null
        case let opt as Any? where opt == nil:
            return .null
        case let num as Float:
            return .number(num)
        case let num as Int:
            return .number(Float(num))
        case let str as String:
            return .string(str)
        case let bool as Bool:
            return .bool(bool)
        case let array as [Any]:
            return .array(array.map { JSON.make(from: $0) })
        case let dict as [String: Any]:
            return .object(dict.mapValues { JSON.make(from: $0) })
        default:
            return .null
        }
    }
}

extension JSON {

    /// Create a JSON value from an `Encodable`. This will give you access to the “raw”
    /// encoded JSON value the `Encodable` is serialized into.
    public init<T: Encodable>(encodable: T) throws {
        let encoded = try JSONEncoder().encode(encodable)
        self = try JSONDecoder().decode(JSON.self, from: encoded)
    }
}

extension Decodable {

    /// Initialize a `Decodable` type from a given JSON instance.
    public init(byDecoding json: JSON) throws {
        let jsonData = try JSONEncoder().encode(json)
        self = try JSONDecoder().decode(Self.self, from: jsonData)
    }
}

// MARK: - Heterogenous collections

extension Array where Element == Any {

    /// Returns a JSON structure from any heterogenous array where values default to `.null`
    public var asJSON: JSON {
        return JSON.make(from: self)
    }
}

extension Array where Element == Any? {

    /// Returns a JSON structure from any heterogenous array with optionals where values default to `.null`
    public var asJSON: JSON {
        return JSON.make(from: self)
    }
}

extension Dictionary where Key == String, Value == Any {

    /// Returns a JSON structure from any heterogenous dictionary where values default to `.null`
    public var asJSON: JSON {
        return JSON.make(from: self)
    }
}

extension Dictionary where Key == String, Value == Any? {

    /// Returns a JSON structure from any heterogenous dictionary with optionals where values default to `.null`
    public var asJSON: JSON {
        return JSON.make(from: self)
    }
}

// MARK: - Literal expression

extension JSON: ExpressibleByBooleanLiteral {

    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension JSON: ExpressibleByNilLiteral {

    public init(nilLiteral: ()) {
        self = .null
    }
}

extension JSON: ExpressibleByArrayLiteral {

    public init(arrayLiteral elements: JSON...) {
        self = .array(elements)
    }
}

extension JSON: ExpressibleByDictionaryLiteral {

    public init(dictionaryLiteral elements: (String, JSON)...) {
        var object: [String:JSON] = [:]
        for (k, v) in elements {
            object[k] = v
        }
        self = .object(object)
    }
}

extension JSON: ExpressibleByFloatLiteral {

    public init(floatLiteral value: Float) {
        self = .number(value)
    }
}

extension JSON: ExpressibleByIntegerLiteral {

    public init(integerLiteral value: Int) {
        self = .number(Float(value))
    }
}

extension JSON: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self = .string(value)
    }
}
