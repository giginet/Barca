import Foundation
@testable import BarcaKit
import XCTest

struct Foo: Decodable {
    var name: String
}

final class ConfigLoaderTests: XCTestCase {
    private let loader = ConfigLoader()
    
    func testLoading() {
        let toml = """
[[repositories]]
name = "RxSwift"

[[repositories.targets]]
name = "RxSwift"
type = "static"

[[repositories.targets]]
name = "RxCocoa"
type = "dynamic"
"""
        do {
            let config = try loader.loader(from: toml.data(using: .utf8)!)
            XCTAssertEqual(config.repositories.count, 1)
            let repository = config.repositories.first!
            XCTAssertEqual(repository.targets.count, 2)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
