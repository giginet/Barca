import Foundation
import PathKit
import XcodeProj

struct Injector {
    init(projectPath: Path) throws {
        let xcodeproj = try XcodeProj(path: projectPath)
    }
}
