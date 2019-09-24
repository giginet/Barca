import Foundation
import XCTest
import XcodeProj
import PathKit
import Shell
@testable import BarcaKit

final class InjectorTests: XCTestCase {
    let injector = Injector()
    let cleaner = PackageCleaner(shell: Shell(),
                                 gitURL: URL(fileURLWithPath: "/usr/bin/git"))

    private func assertFrameworkType(_ targetName: String,
                                     of package: Package,
                                     shouldBe frameworkType: FrameworkType,
                                     line: UInt) {
        guard let target = package.targets.first(where: { $0.name == targetName }) else {
            return XCTFail("Could not found \(targetName) in \(package.repositoryName).")
        }
        let allConfiguration = target.buildConfigurationList!.buildConfigurations
        for configuration in allConfiguration {
            XCTAssertEqual(configuration.buildSettings.frameworkType,
                           frameworkType,
                           line: line)
        }
    }

    func testInjectWithSingleTarget() {
        let expected: [(String, FrameworkType, UInt)] = [
            ("Crossroad", .dynamic, #line)
        ]
        let projectBase = buildFixtureURL(from: "RegularProject")
        let singlePackage = projectBase.appendingPathComponent("Carthage")
            .appendingPathComponent("Checkouts")
            .appendingPathComponent("Crossroad")
        let xcodeprojURL = singlePackage.appendingPathComponent("Crossroad.xcodeproj")
        let xcodeproj = try! XcodeProj(pathString: xcodeprojURL.path)

        let package = Package(repositoryPath: Path(singlePackage.path),
                              xcodeProj: xcodeproj)
        assertFrameworkType("Crossroad", of: package, shouldBe: .dynamic, line: #line)

        do {
            for (targetName, type, line) in expected {
                let result = try injector.inject(type, into: targetName, of: package)
                defer { try! cleaner.clean(package.repositoryPath) }
                XCTAssertEqual(result, type, line: line)
                assertFrameworkType(targetName, of: package, shouldBe: type, line: line)
            }
        } catch {
            XCTFail("Could not write project \(error.localizedDescription)")
        }
    }

    func testInjectWithMultipleTargets() {
        let expected: [(String, FrameworkType, UInt)] = [
            ("RxSwift", .dynamic, #line),
            ("RxCocoa", .dynamic, #line),
            ("RxTest", .static, #line),
            ("RxBlocking", .static, #line),
            ("RxRelay", .dynamic, #line)
        ]
        let projectBase = buildFixtureURL(from: "RegularProject")
        let singlePackage = projectBase.appendingPathComponent("Carthage")
            .appendingPathComponent("Checkouts")
            .appendingPathComponent("RxSwift")
        let xcodeprojURL = singlePackage.appendingPathComponent("Rx.xcodeproj")
        let xcodeproj = try! XcodeProj(pathString: xcodeprojURL.path)

        let package = Package(repositoryPath: Path(singlePackage.path),
                              xcodeProj: xcodeproj)
        expected.forEach { (targetName, _, line) in
            assertFrameworkType(targetName, of: package, shouldBe: .dynamic, line: line)
        }

        do {
            for (targetName, type, line) in expected {
                let result = try injector.inject(type, into: targetName, of: package)
                defer { try! cleaner.clean(package.repositoryPath) }
                XCTAssertEqual(result, type, line: line)
                assertFrameworkType(targetName, of: package, shouldBe: type, line: line)
            }
        } catch {
            XCTFail("Could not write project \(error.localizedDescription)")
        }
    }

    func testInjectWithUnknownTarget() {
        let expected: [(String, FrameworkType, UInt)] = [
            ("RxUnknown", .dynamic, #line)
        ]
        let projectBase = buildFixtureURL(from: "RegularProject")
        let singlePackage = projectBase.appendingPathComponent("Carthage")
            .appendingPathComponent("Checkouts")
            .appendingPathComponent("RxSwift")
        let xcodeprojURL = singlePackage.appendingPathComponent("Rx.xcodeproj")
        let xcodeproj = try! XcodeProj(pathString: xcodeprojURL.path)

        let package = Package(repositoryPath: Path(singlePackage.path),
                              xcodeProj: xcodeproj)
        do {
            for (targetName, type, _) in expected {
                _ = try injector.inject(type, into: targetName, of: package)
                defer { try! cleaner.clean(package.repositoryPath) }
                XCTFail("Injecting to unknown target should fail")
            }
        } catch {
            XCTAssertEqual((error as? BarcaError)?.description, #"Target "RxUnknown" is not found in this project."#)
        }
    }
}
