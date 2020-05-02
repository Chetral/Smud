import XCTest
@testable import Smud

final class SmudTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Smud().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
