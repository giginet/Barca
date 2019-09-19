import Foundation
import BarcaKit

let projectRoot = URL(fileURLWithPath: "/Users/giginet/work/Swift/BarcaPlayground")

do {
    let handler = try Handler(projectRoot: projectRoot)
    try handler.inject()
} catch {
    print(error.localizedDescription)
}
