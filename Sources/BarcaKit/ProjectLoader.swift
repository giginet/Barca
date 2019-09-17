import Foundation
import PathKit
import XcodeProj

final class ProjectLoader {
    enum Error: Swift.Error {
        case projectNotFound
        case couldNotLoadProject(Path)
    }
    
    func load(_ repositoryName: String, from repositoryPath: Path) throws -> Package {
        guard let projectPath = repositoryPath.glob("*.xcodeproj").first else {
            throw Error.projectNotFound
        }
        guard let xcodeproj = try? XcodeProj(path: projectPath) else {
            throw Error.couldNotLoadProject(projectPath)
        }
        return Package(repositoryPath: projectPath, xcodeProj: xcodeproj)
    }
}
