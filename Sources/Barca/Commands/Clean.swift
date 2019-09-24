import Foundation
import Commandant
import BarcaKit
import PathKit

struct CleanOptions: OptionsProtocol {
    typealias ClientError = FrontendError
    var projectRoot: Path
    var cleanTarget: Handler.CleanTarget

    static func create(_ projectRoot: Path) -> (String?) -> CleanOptions {
        return { packageName in
            let cleanTarget: Handler.CleanTarget
            if let name = packageName {
                cleanTarget = .package(name)
            } else {
                cleanTarget = .all
            }
            return CleanOptions(projectRoot: projectRoot, cleanTarget: cleanTarget)
        }
    }

    static func evaluate(_ m: CommandMode) -> Result<CleanOptions, CommandantError<FrontendError>> {
        return create
            <*> m <| Option<Path>(key: "project-root", defaultValue: Path(""), usage: "Project root path")
            <*> m <| Option<String?>(key: "package-name", defaultValue: nil, usage: "Package name to clean up")
    }
}

struct CleanCommand: CommandProtocol {
    let verb: String = "clean"
    let function: String = "Clean up dirty packages"
    let formatter = Formatter()

    func run(_ options: CleanOptions) -> Result<(), FrontendError> {
        do {
            let handler = try Handler(projectRoot: options.projectRoot.url)
            try handler.clean(options.cleanTarget)
            return .success(())
        } catch {
            formatter.printError(error)
            return .failure(.init(error))
        }
    }

    typealias Options = CleanOptions
    typealias ClientError = FrontendError
}
