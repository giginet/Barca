import Foundation
import PathKit
import Shell

struct PackageCleaner {
    var shell: Shell
    var gitURL: URL

    enum Error: Swift.Error {
        case repositoryNotFound(URL)
        case gitExecutableNotFound(URL)
    }

    private func executeGit(at repositoryPath: Path, arguments: String...) throws -> Result<String, ShellError> {
        guard Path(gitURL.path).exists else {
            throw Error.gitExecutableNotFound(gitURL)
        }
        let result = shell.capture([gitURL.path] + arguments,
                                   workingDirectoryPath: repositoryPath,
                                   env: nil)
        if case .failure(let error) = result {
            switch error.processError {
            case .shell(_, let code) where code == 127:
                throw Error.repositoryNotFound(repositoryPath.url)
            case .missingExecutable:
                throw Error.gitExecutableNotFound(gitURL)
            default:
                return result
            }
        }
        return result
    }

    func shouldClean(_ repositoryPath: Path) throws -> Bool {
        var result: Bool = false
        try repositoryPath.chdir {
            let executionResult = try executeGit(at: repositoryPath, arguments: "diff", "--quiet")
            switch executionResult {
            case .success:
                result = false
            case .failure:
                result = true
            }
        }
        return result
    }

    @discardableResult
    func clean(_ repositoryPath: Path) throws -> Bool {
        guard try shouldClean(repositoryPath) else {
            return false
        }
        var result: Bool = false
        try repositoryPath.chdir {
            let executionResult = try self.executeGit(at: repositoryPath, arguments: "reset", "--hard", "HEAD")
            switch executionResult {
            case .success:
                result = true
            case .failure:
                result = false
            }
        }
        return result
    }
}
