import Foundation
import PathKit
import XcodeProj

struct Package {
    var repositoryPath: Path
    var xcodeProj: XcodeProj
    var repositoryName: String {
        return repositoryPath.url.lastPathComponent
    }
    var targets: [PBXTarget] {
        return xcodeProj.pbxproj.nativeTargets
    }
}
