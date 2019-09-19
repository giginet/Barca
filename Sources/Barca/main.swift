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

private let main = Group {
    $0.command("apply", description: "Apply framework types to all packages") { (projectRoot: Path) in
        do {
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
    
    $0.command("clean", description: "Clean up all dirty packages") { (projectRoot: Path) in
        formatter.printError("Unsupported")
    }
    
    $0.command("version", description: "Display current version") {
        print(BarcaKit.version)
    }
}

main.run()
