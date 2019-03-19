//
// Copyright © 2019 Zoul. All rights reserved.
//

import XCTest
@testable import CodingKit

class EqualityTests: XCTestCase {

    func testEquality() {
        XCTAssertEqual([] as JSON, [] as JSON)
        XCTAssertEqual(nil as JSON, nil as JSON)
        XCTAssertEqual(1 as JSON, 1 as JSON)
        XCTAssertEqual(1 as JSON, 1.0 as JSON)
        XCTAssertEqual("foo" as JSON, "foo" as JSON)
        XCTAssertEqual(["foo": ["bar"]] as JSON, ["foo": ["bar"]] as JSON)
    }

    func testHeterogenousArray() {
        let json: JSON = [nil, 1, "two", 3.0]
        XCTAssertEqual(json[0], .null)
        XCTAssertEqual(json[1].intValue, 1)
        XCTAssertEqual(json[2].stringValue, "two")
        XCTAssertEqual(json[3].floatValue, 3.0)
    }
}
