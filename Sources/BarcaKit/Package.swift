import Foundation
import PathKit

struct Package {
    var carthagePackage: Cartfile.Package
    var repositoryName: String {
        switch carthagePackage.source {
        case .github(let slug):
            return slug.repository
        case .git(let url):
            return url.deletingPathExtension().lastPathComponent
        }
    }
    var repositoryPath: Path {
        return Path("./Carthage/Checkouts/\(repositoryName)")
    }
    var targets: Set<String>
}
