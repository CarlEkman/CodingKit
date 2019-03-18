//
//  Copyright © 2019 Carl Ekman. All rights reserved.
//

import XCTest
@testable import CodingKit

class InferenceTests: XCTestCase {

    func testString() {
        XCTAssertNoThrow(try { let _: String = try JSON.string("string")^ }())
        XCTAssertThrowsError(try { let _: String = try JSON.bool(true)^ }())
        XCTAssertThrowsError(try { let _: String = try JSON.number(3.14)^ }())
    }

    func testBool() {
        XCTAssertNoThrow(try { let _: Bool = try JSON.bool(true)^ }())
        XCTAssertNoThrow(try { let _: Bool = try JSON.bool(false)^ }())
        XCTAssertThrowsError(try { let _: Bool = try JSON.string("true")^ }())
        XCTAssertThrowsError(try { let _: Bool = try JSON.number(3.14)^ }())
    }

    func testFloat() {
        XCTAssertNoThrow(try { let _: Float = try JSON.number(3.14)^ }())
        XCTAssertNoThrow(try { let _: Float = try JSON.number(-3.0)^ }())
        XCTAssertThrowsError(try { let _: Float = try JSON.bool(true)^ }())
        XCTAssertThrowsError(try { let _: Float = try JSON.string("3.14")^ }())
    }

    func testInt() {
        XCTAssertNoThrow(try { let _: Int = try JSON.number(3.0)^ }())
        XCTAssertNoThrow(try { let _: Int = try JSON.number(-3)^ }())
        XCTAssertThrowsError(try { let _: Int = try JSON.bool(true)^ }())
        XCTAssertThrowsError(try { let _: Int = try JSON.string("3.14")^ }())
        XCTAssertThrowsError(try { let _: Int = try JSON.number(3.14)^ }())
    }

    func testArray() {
        XCTAssertNoThrow(try { let _: [Int] = try JSON.array([1, 2, 3])^ }())
        XCTAssertNoThrow(try { let _: [Float] = try JSON.array([1.1, 2.2, 3.3])^ }())
        XCTAssertNoThrow(try { let _: [String] = try JSON.array(["foo", "bar", "baz"])^ }())
        XCTAssertThrowsError(try { let _: [Int] = try JSON.array([1.0, 2.0, 3.5])^ }())
        XCTAssertThrowsError(try { let _: [String] = try JSON.string("3.14")^ }())
    }

    func testObject() {
        XCTAssertNoThrow(try { let _: [String: Int] = try JSON.object(["first": 1, "second": 2])^ }())
        XCTAssertThrowsError(try { let _: [String: Int] = try JSON.object(["first": "first"])^ }())
    }

    func testStructuredData() throws {
        let json = try JSON(encodable: Person(name: "Jason", age: 30))
        let age: Int = try json.age^
        XCTAssertEqual(age, 30)
        XCTAssertThrowsError(try { let _: Int = try json.name^ }())
    }
}
