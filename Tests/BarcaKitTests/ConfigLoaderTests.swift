import Foundation
@testable import BarcaKit
import XCTest

final class ConfigLoaderTests: XCTestCase {
    private let loader = ConfigLoader()
    
    func testLoading() {
        let toml = """
[repository]
[repository.RxSwift]
RxCocoa = "dynamic"
RxSwift = "dynamic"
RxTest = "dynamic"

[repository.Crossroad]
Crossroad = "dynamic"
"""
        do {
            let config = try loader.load(toml.data(using: .utf8)!)
            let repository = config.repositories.RxSwift!
            XCTAssertEqual(repository.RxCocoa, .dynamic)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
