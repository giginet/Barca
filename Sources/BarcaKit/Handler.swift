import Foundation
import PathKit
import XcodeProj

private let projectLoader: ProjectLoader = .init()
private let injector = Injector()
private let configLoader = ConfigLoader()
private let parser = CartfileParser()

public final class Handler {
    private let packages: [Package]
    private let config: Config
    
    enum Error: Swift.Error {
        case couldNotFoundConfig
        case couldNotFoundResolvedCartfile
    }
    
    public init(projectRoot: URL) throws {
        let barcaConfigPath = Path(projectRoot.appendingPathComponent("Barca.toml").path)
        guard barcaConfigPath.exists else {
            throw Error.couldNotFoundConfig
        }
        config = try configLoader.load(from: barcaConfigPath.url)
        
        let cartfileResolvedPath = Path(projectRoot.appendingPathComponent("Cartfile.resolved").path)
        guard cartfileResolvedPath.exists else {
            throw Error.couldNotFoundResolvedCartfile
        }
        
        let cartfile = try parser.parse(cartfileResolvedURL: cartfileResolvedPath.url)
        packages = cartfile.packages.compactMap { package in
            let repositoryPath = Path(projectRoot
                .appendingPathComponent("Carthage")
                .appendingPathComponent("Checkouts")
                .appendingPathComponent(package.name).path)
            return try? projectLoader.load(package.name, from: repositoryPath)
        }
    }
    
    public func inject() throws {
        for package in packages {
            try inject(for: package)
        }
    }
    
    func inject(for package: Package) throws {
        let repository = config.repositories[dynamicMember: package.repositoryName]
        guard let targets = repository?.targets else {
            return
        }
        for target in targets {
            try injector.inject(target.type, into: target.name, of: package)
        }
    }
}
