import Foundation
@testable import BarcaKit
import XCTest

final class ConfigLoaderTests: XCTestCase {
    private let loader = ConfigLoader()

    func testLoading() {
        let toml = """
[packages.RxSwift]
RxCocoa = "dynamic"
RxSwift = "dynamic"
RxTest = "dynamic"

[packages.Crossroad]
Crossroad = "dynamic"
"""
        do {
            let config = try loader.load(toml.data(using: .utf8)!)
            let repository = config.packages.RxSwift!
            XCTAssertEqual(repository.RxCocoa, .dynamic)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
