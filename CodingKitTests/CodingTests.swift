//
// Copyright © 2019 Zoul. All rights reserved.
//

import XCTest
@testable import CodingKit

class CodingTests: XCTestCase {
    
    @available(OSX 10.13, *)
    func testEncoding() throws {
        let json: JSON = [
            "num": 1,
            "str": "baz",
            "bool": true,
            "null": nil,
            "array": [],
            "obj": [:],
        ]
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let encoded = try encoder.encode(json)
        let str = String(data: encoded, encoding: .utf8)!
        XCTAssertEqual(str, """
            {"array":[],"bool":true,"null":null,"num":1,"obj":{},"str":"baz"}
            """)
    }

    func testFragmentEncoding() {
        let fragments: [JSON] = ["foo", 1, true, nil]
        for f in fragments {
            XCTAssertThrowsError(try JSONEncoder().encode(f))
        }
    }

    func testDecoding() throws {
        let input = """
            {"array":[1],"num":1,"bool":true,"obj":{},"null":null,"str":"baz"}
            """
        let json = try! JSONDecoder().decode(JSON.self, from: input.data(using: .utf8)!)
        XCTAssertEqual(json, [
            "num": 1,
            "str": "baz",
            "bool": true,
            "null": nil,
            "array": [1],
            "obj": [:],
        ])
    }

    func testDecodingBool() throws {
        XCTAssertEqual(try JSONDecoder().decode(JSON.self, from: "{\"b\":true}".data(using: .utf8)!), ["b":true])
        XCTAssertEqual(try JSONDecoder().decode(JSON.self, from: "{\"n\":1}".data(using: .utf8)!), ["n":1])
    }

    func testEmptyCollectionDecoding() throws {
        XCTAssertEqual(try JSONDecoder().decode(JSON.self, from: "[]".data(using: .utf8)!), [])
        XCTAssertEqual(try JSONDecoder().decode(JSON.self, from: "{}".data(using: .utf8)!), [:])
    }

    func testDebugDescriptions() {
        let fragments: [JSON] = ["foo", 1, true, nil]
        let descriptions = fragments.map { $0.debugDescription }
        XCTAssertEqual(descriptions, ["\"foo\"", "1.0", "true", "null"])
    }

    func testHeterogenousCollections() {
        let one = 1
        let zero = 0
        let string = "string"
        let bool = true
        let dict = [
            "one": one,
            "zero": zero,
            "string": string,
            "bool": bool,
            "null": nil,
            "array": [],
            "object": [:],
            ] as [String : Any?]

        let json: JSON = [
            "one": 1,
            "zero": 0,
            "string": "string",
            "bool": true,
            "null": nil,
            "array": [],
            "object": [:],
            ]
        XCTAssertEqual(json, dict.asJSON)
    }

    private struct Person: Codable {
        let name: String
        let age: Int
    }

    func testDecodableFromLiteral() throws {
        let jason = try Person(byDecoding: [
            "name": "Jason",
            "age": 30])
        XCTAssertEqual(jason.name, "Jason")
        XCTAssertEqual(jason.age, 30)
    }

    func testDecodableFromRaw() throws {
        let input = """
            {"name": "Jason", "age": 30}
            """
        let json = try! JSONDecoder().decode(JSON.self, from: input.data(using: .utf8)!)
        let jason = try Person(byDecoding: json)
        XCTAssertEqual(jason.name, "Jason")
        XCTAssertEqual(jason.age, 30)
    }

    func testDecodingFromArray() throws {
        let input = """
            [{"name": "Jason", "age": 30},
             {"name": "Annie", "age": 25},
             {"name": "Peter", "age": 45}]
        """
        let json = try JSON(serialized: input)
        let people: [Person] = try json^
        XCTAssertEqual(people.count, 3)
        XCTAssertEqual(people[0].name, "Jason")
        XCTAssertEqual(people[0].age, 30)
        XCTAssertEqual(people[1].name, "Annie")
        XCTAssertEqual(people[1].age, 25)
        XCTAssertEqual(people[2].name, "Peter")
        XCTAssertEqual(people[2].age, 45)
    }

    func testDecodingNestedStructures() throws {
        let input = """
            {"teacher": {"name": "Alice", "age": 36},
             "students": [
                {"name": "Tim", "age": 8},
                {"name": "Sara", "age": 8},
                {"name": "Linn", "age": 7}
             ]}
        """
        let json = try JSON(serialized: input)

        let classroom: Classroom = try json^

        let teacher = classroom.teacher
        XCTAssertEqual(teacher.name, "Alice")
        XCTAssertEqual(teacher.age, 36)

        let students = classroom.students
        XCTAssertEqual(students.count, 3)
        XCTAssertEqual(students[0].name, "Tim")
        XCTAssertEqual(students[0].age, 8)
        XCTAssertEqual(students[1].name, "Sara")
        XCTAssertEqual(students[1].age, 8)
        XCTAssertEqual(students[2].name, "Linn")
        XCTAssertEqual(students[2].age, 7)
    }
}
