import Foundation
import BarcaKit

let projectRoot = URL(fileURLWithPath: "/Users/giginet/work/Swift/BarcaPlayground")
let formatter = Formatter()
do {
    let handler = try Handler(projectRoot: projectRoot)
    let result = try handler.inject()
    formatter.printResult(result)
} catch {
    switch error {
    case let barcaError as BarcaError:
        formatter.printError(barcaError.description)
    default:
        formatter.printError(error.localizedDescription)
    }
}
