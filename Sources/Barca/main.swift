import Foundation
import BarcaKit
import Commandant
import PathKit

let registry = CommandRegistry<FrontendError>()
registry.register(ApplyCommand())

let helpCommand = HelpCommand(registry: registry)
registry.register(helpCommand)

var arguments = CommandLine.arguments
// Remove the executable name.
assert(arguments.count >= 1)
arguments.remove(at: 0)

registry.main(defaultVerb: helpCommand.verb) { error in
    fputs(error.description + "\n", stderr)
}
