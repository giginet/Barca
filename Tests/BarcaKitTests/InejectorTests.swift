import Foundation
import XCTest
import XcodeProj
import PathKit
@testable import BarcaKit

final class InjectorTests: XCTestCase {
    let injector = Injector()
    
    private func assertFrameworkType(_ targetName: String,
                                     of package: Package,
                                     shouldBe frameworkType: FrameworkType,
                                     line: UInt) {
        guard let target = package.targets.first(where: { $0.name == targetName }) else {
            return XCTFail("Could not found \(targetName) in \(package.repositoryName).")
        }
        let allConfiguration = target.buildConfigurationList!.buildConfigurations
        for configuration in allConfiguration {
            print(configuration.buildSettings)
            XCTAssertEqual(configuration.buildSettings.frameworkType,
                           frameworkType,
                           line: line)
        }
    }
    
    func testInjectWithSingleTarget() {
        let expected: [(String, FrameworkType, UInt)] = [
            ("Crossroad", .dynamic, #line),
        ]
        let projectBase = buildFixtureURL(from: "RegularProject")
        let singlePackage = projectBase.appendingPathComponent("Carthage")
            .appendingPathComponent("Checkouts")
            .appendingPathComponent("Crossroad")
        let xcodeprojURL = singlePackage.appendingPathComponent("Crossroad.xcodeproj")
        let xcodeproj = try! XcodeProj(pathString: xcodeprojURL.path)
        
        let package = Package(repositoryPath: Path(singlePackage.path),
                              xcodeProj: xcodeproj)
        assertFrameworkType("Crossroad", of: package, shouldBe: .static, line: #line)
        
        do {
            let result = try injector.inject(.dynamic, into: "Crossroad", of: package)
            XCTAssertEqual(result, .dynamic)
            for (target, type, line) in expected {
                assertFrameworkType(target, of: package, shouldBe: type, line: line)
            }
        } catch {
            XCTFail("Could not write project \(error.localizedDescription)")
        }
    }
}
