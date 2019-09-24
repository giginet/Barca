import Foundation
import BarcaKit

private extension FrameworkType {
    var displayName: String {
        switch self {
        case .dynamic:
            return "Dynamic Framework"
        case .static:
            return "Static Framework"
        }
    }
}

struct Formatter {
    func printError(_ errorDescription: String) {
        print("❗\(errorDescription, foregroundColor: .red)")
    }

    func printError(_ error: Error) {
        switch error {
        case let barcaError as BarcaError:
            printError(barcaError.description)
        default:
            printError(error.localizedDescription)
        }
    }
}

struct StandardOutput: Output {
    func print(_ message: String) {
        Swift.print(message)
    }
}
