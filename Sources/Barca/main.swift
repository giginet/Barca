import Foundation
import BarcaKit

let projectRoot = URL(fileURLWithPath: "/Users/giginet/work/Swift/BarcaPlayground")

do {
    let handler = try Handler(projectRoot: projectRoot)
    let result = try handler.inject()
    for (package, targets) in result {
        print(package)
        targets.forEach { print($0) }
    }
} catch {
    switch error {
    case let barcaError as BarcaError:
        print(barcaError.description)
    default:
        print(error.localizedDescription)
    }
}
