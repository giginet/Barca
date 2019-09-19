import Foundation
import XCTest
@testable import BarcaKit

class CartfileParserTests: XCTestCase {
    let parser = CartfileParser()

    func testParsingCartfiles() {
        let content = """
github "giginet/Crossroad" "3.0.0"
"""
        let cartfile = try! parser.parse(content: content)
        XCTAssertEqual(cartfile.packages.count, 1)
        XCTAssertEqual(cartfile.packages.first!.source, .github(Cartfile.Slug("giginet/Crossroad")!))
        XCTAssertEqual(cartfile.packages.first!.version, "3.0.0")
    }
}
