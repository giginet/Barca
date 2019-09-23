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
        mock.stub(["/usr/bin/git", "diff", "--quiet"],
                  shouldBeTerminatedOnParentExit: true,
                  workingDirectoryPath: repositoryPath,
                  env: nil,
                  stdout: [],
                  stder: [],
                  code: clean ? 0 : 1)
    }
    
    private func dirty(repository: Path) {
        let shell = Shell()
        _ = shell.sync(["echo \"// Dirty\" >> \(repository + "Package.swift")"])
    }
    
    override func setUp() {
        super.setUp()
        
        try? cleaner.clean(repositoryPath)
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
    
    func testShouldCleanWithRealGit() {
        dirty(repository: repositoryPath)
        let result = try! cleaner.shouldClean(repositoryPath)
        XCTAssertTrue(result)
    }
    
    func testShouldNotCleanWithRealGit() {
        let result = try! cleaner.shouldClean(repositoryPath)
        XCTAssertTrue(result)
    }
    
    override func tearDown() {
        super.tearDown()
        
        try? cleaner.clean(repositoryPath)
    }
}
