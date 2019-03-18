//
//  Copyright © 2019 Carl Ekman. All rights reserved.
//

import Foundation

internal enum InferenceError: Error {
    case invalidStringValue
    case invalidBoolValue
    case invalidFloatValue
    case invalidIntValue
    case invalidArrayValue
    case invalidObjectValue
}

/// The inference operator
postfix operator ^

// MARK: - Type inferred functions

// These functions are wrappers for querying values
// That throw if the value returned is `nil`.

/// Try to instantiate a string value
public postfix func ^(json: JSON) throws -> String {
    guard let value = json.stringValue else {
        throw InferenceError.invalidStringValue
    }
    return value
}

/// Try to instantiate a boolean value
public postfix func ^(json: JSON) throws -> Bool {
    guard let value = json.boolValue else {
        throw InferenceError.invalidBoolValue
    }
    return value
}

/// Try to instantiate a floating point value
public postfix func ^(json: JSON) throws -> Float {
    guard let value = json.floatValue else {
        throw InferenceError.invalidFloatValue
    }
    return value
}

/// Try to instantiate an integer value
public postfix func ^(json: JSON) throws -> Int {
    guard let value = json.intValue else {
        throw InferenceError.invalidIntValue
    }
    return value
}

/// Try to instantiate an array of JSON values
public postfix func ^(json: JSON) throws -> [JSON] {
    guard let value = json.arrayValue else {
        throw InferenceError.invalidArrayValue
    }
    return value
}

/// Try to instantiate a JSON object
public postfix func ^(json: JSON) throws -> [String: JSON] {
    guard let value = json.objectValue else {
        throw InferenceError.invalidObjectValue
    }
    return value
}

/// Try to instantiate a decodable type
public postfix func ^<T: Decodable>(json: JSON) throws -> T {
    return try JSONDecoder().decode(T.self, from: JSONEncoder().encode(json))
}
