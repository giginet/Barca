import Foundation
import PathKit
import XcodeProj

final class ProjectLoader {
    enum Error: BarcaError {
        case projectNotFound(Path)
        case couldNotLoadProject(Path)

        var description: String {
            switch self {
            case .projectNotFound(let repositoryPath):
                return "Any xcodeproj is not found in \(repositoryPath.absolute())."
            case .couldNotLoadProject(let projectPath):
                return "Could not load project \(projectPath.absolute())"
            }
        }
    }

    func load(_ repositoryName: String, from repositoryPath: Path) throws -> Package {
        guard let projectPath = repositoryPath.glob("*.xcodeproj").first else {
            throw Error.projectNotFound(repositoryPath)
        }
        guard let xcodeproj = try? XcodeProj(path: projectPath) else {
            throw Error.couldNotLoadProject(projectPath)
        }
        return Package(repositoryPath: repositoryPath, xcodeProj: xcodeproj)
    }
}
