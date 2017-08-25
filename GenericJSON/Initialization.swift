import Foundation

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

extension JSON {

    public init(_ value: Any) throws {
        switch value {
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
                throw Error.decodingError
        }
    }
}

extension JSON {

    public init<T: Codable>(codable: T) throws {
        let encoded = try JSONEncoder().encode(codable)
        self = try JSONDecoder().decode(JSON.self, from: encoded)
    }
}
