import Foundation
import Commandant
import BarcaKit
import PathKit

struct ApplyOptions: OptionsProtocol {
    typealias ClientError = FrontendError
    var projectRoot: Path

    static func create(_ projectRoot: Path) -> ApplyOptions {
        return ApplyOptions(projectRoot: projectRoot)
    }

    static func evaluate(_ m: CommandMode) -> Result<ApplyOptions, CommandantError<FrontendError>> {
        return create
            <*> m <| Option<Path>(key: "project-root", defaultValue: Path(""), usage: "Project root path")
    }
}

struct ApplyCommand: CommandProtocol {
    let verb: String = "apply"
    let function: String = "Apply framework types to all packages"
    let formatter = Formatter()

    func run(_ options: ApplyOptions) -> Result<(), FrontendError> {
        do {
            let handler = try Handler(projectRoot: options.projectRoot.url)
            let result = try handler.apply()
            formatter.printResult(result)
            return .success(())
        } catch {
            formatter.printError(error)
            return .failure(.init(error))
        }
    }

    typealias Options = ApplyOptions
    typealias ClientError = FrontendError
}
