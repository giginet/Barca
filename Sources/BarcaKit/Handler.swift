import Foundation
import PathKit
import XcodeProj

private let projectLoader: ProjectLoader = .init()

public final class Handler {
    private let packages: [Package]
    
    enum Error: Swift.Error {
        case couldNotFoundResolvedCartfile
    }
    
    public init(projectRoot: URL) throws {
        let cartfileResolvedPath = Path(projectRoot.appendingPathComponent("Cartfile.resolved").path)
        guard cartfileResolvedPath.exists else {
            throw Error.couldNotFoundResolvedCartfile
        }
        let parser = CartfileParser()
        let cartfile = try parser.parse(cartfileResolvedURL: cartfileResolvedPath.url)
        
        packages = cartfile.packages.compactMap { package in
            let repositoryPath = Path(projectRoot
                .appendingPathComponent("Carthage")
                .appendingPathComponent("Checkouts")
                .appendingPathComponent(package.name).path)
            return try? projectLoader.load(package.name, from: repositoryPath)
        }
        print(packages)
    }
}
