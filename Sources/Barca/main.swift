import Foundation
import BarcaKit
import Commander
import PathKit

extension Path: ArgumentConvertible {
    public init(parser: ArgumentParser) throws {
        let path = parser.shift()
        self.init(path ?? ".")
    }
}

private let formatter = Formatter()

private func parseProjectRoot(from parser: ArgumentParser) -> Path {
    do {
        let projectRootString = try parser.shiftValue(for: "project-root", or: "p") ?? "."
        return Path(projectRootString)
    } catch {
        return Path(".")
    }
}

private let main = Group {
    $0.command("apply", description: "Apply framework types to all packages") { (parser: ArgumentParser) in
        do {
            let projectRoot = parseProjectRoot(from: parser)
            let handler = try Handler(projectRoot: projectRoot.url)
            let result = try handler.apply()
            formatter.printResult(result)
        } catch {
            switch error {
            case let barcaError as BarcaError:
                formatter.printError(barcaError.description)
            default:
                formatter.printError(error.localizedDescription)
            }
        }
    }

    $0.command("clean", description: "Clean up all dirty packages") { (packageName: String?, parser: ArgumentParser) in
        do {
            let projectRoot = parseProjectRoot(from: parser)
            let handler = try Handler(projectRoot: projectRoot.url)
            if let name = packageName {
                try handler.clean(.package(name))
            } else {
                try handler.clean(.all)
            }
        }
    }
}

main.run(BarcaKit.version)
