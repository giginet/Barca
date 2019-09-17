import Foundation
import XCTest
import PathKit
@testable import BarcaKit

final class PackageTests: XCTestCase {
    func testPackage() {
        let slug = Cartfile.Slug("giginet/Crossroad")!
        let carthagePackage = Cartfile.Package(source: .github(slug), version: "2.0.0")
//        let package = Package(carthagePackage: carthagePackage, targets: [])
//        XCTAssertEqual(package.repositoryName, "Crossroad")
//        XCTAssertEqual(package.repositoryPath, Path("./Carthage/Checkouts/Crossroad"))
    }
}
