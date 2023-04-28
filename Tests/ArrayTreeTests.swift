//
// Copyright (c) Vatsal Manot
//

@testable import Compute

import Swallow
import XCTest

final class ArrayTreeTests: XCTestCase {
    func testArrayTree() {
        let foo = ArrayTree<Int>(0) {
            [
                1: [
                    1: [1, 0],
                    0: [1, 0]
                ]
            ]
        }
    }
}
