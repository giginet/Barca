import Foundation
import XCTest
import Shell
import ShellTesting
import PathKit
@testable import BarcaKit

final class PackageCleanerTests: XCTestCase {
    let mock: MockShell = {
        return Shell.mock()
    }()
    lazy var cleaner: PackageCleaner = {
        return PackageCleaner(shell: mock,
                              gitURL: URL(fileURLWithPath: "/usr/bin/git"))
    }()
    var repositoryPath: Path {
        return Path(buildFixtureURL(from: "RegularProject")
            .appendingPathComponent("Carthage")
            .appendingPathComponent("Checkouts")
            .appendingPathComponent("RxSwift").path)
    }

    private func stub(clean: Bool) {
        mock.stub(["/usr/bin/git", "status", "--porcelain"],
                  shouldBeTerminatedOnParentExit: true,
                  workingDirectoryPath: repositoryPath,
                  env: nil,
                  stdout: clean ? [] : ["dirty"],
                  stder: [],
                  code: clean ? 0 : 1)
    }

    func testShouldClean() {
        stub(clean: false)
        let result = try! cleaner.shouldClean(repositoryPath)
        XCTAssertTrue(result)
    }

    func testShouldNotClean() {
        stub(clean: true)
        let result = try! cleaner.shouldClean(repositoryPath)
        XCTAssertFalse(result)
    }

    func testCleanForDirtyDirectory() {
        stub(clean: false)
        mock.stub(["/usr/bin/git", "clean", "-fd"],
                  shouldBeTerminatedOnParentExit: true,
                  workingDirectoryPath: repositoryPath,
                  env: nil,
                  stdout: [],
                  stder: [],
                  code: 0)
        let result = try! cleaner.clean(repositoryPath)
        XCTAssertTrue(result)
    }

    func testCleanForCleanedDirctory() {
        stub(clean: true)
        mock.stub(["/usr/bin/git", "clean", "-fd"],
                  shouldBeTerminatedOnParentExit: true,
                  workingDirectoryPath: repositoryPath,
                  env: nil,
                  stdout: [],
                  stder: [],
                  code: 0)
        let result = try! cleaner.clean(repositoryPath)
        XCTAssertFalse(result)
    }

    func testCleanWithInvalidGitPath() {
        let gitURL = URL(fileURLWithPath: "/path/to/invalid/git/path/git")
        let cleaner = PackageCleaner(shell: mock,
                                     gitURL: gitURL)
        XCTAssertThrowsError(try cleaner.clean(repositoryPath)) { error in
            switch error {
            case PackageCleaner.Error.gitExecutableNotFound(let url):
                XCTAssertEqual(url, gitURL)
            default:
                XCTFail("error should be gitExecutableNotFound")
            }
        }
    }
}
