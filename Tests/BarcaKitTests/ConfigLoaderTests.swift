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
[repository]
[repository.RxSwift]
RxCocoa = "dynamic"
RxSwift = "dynamic"
RxTest = "dynamic"

[repository.Crossroad]
Crossroad = "dynamic"
"""
        do {
            let config = try loader.loader(from: toml.data(using: .utf8)!)
            XCTAssertEqual(config.repository.count, 2)
            let repository = config.repository["RxSwift"]!
            XCTAssertEqual(repository["RxCocoa"], .dynamic)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
