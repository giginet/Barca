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
    func printResult(_ result: [String: InjectionResult]) {
        for (packageName, targets) in result {
            print("\(packageName, foregroundColor: .black, backgroundColor: .green)")
            for (targetName, frameworkType) in targets.compactMapValues({ $0 }) {
                print("    ✅ Modified \(targetName, foregroundColor: .green) to \(frameworkType.displayName, foregroundColor: .green)")
            }
        }
    }

    func printError(_ errorDescription: String) {
        print("❗\(errorDescription, foregroundColor: .red)")
    }
}
