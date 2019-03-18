//
//  Copyright © 2019 Carl Ekman. All rights reserved.
//

import Foundation

struct Person: Codable {
    let name: String
    let age: Int
}

struct Classroom: Codable {
    let teacher: Person
    let students: [Person]
}
