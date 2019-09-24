import Foundation
import PathKit
import XcodeProj
import Shell

private let projectLoader: ProjectLoader = .init()
private let injector = Injector()
private let configLoader = ConfigLoader()
private let parser = CartfileParser()

private let defaultGitURL = URL(fileURLWithPath: "/usr/bin/git")

public typealias InjectionResult = [String: FrameworkType?]

public final class Handler {
    private let packages: [Package]
    private let config: Config

    enum Error: BarcaError {
        case couldNotFoundConfig(URL)
        case couldNotFoundResolvedCartfile(URL)
        case couldNotFoundPackage(String)

        var description: String {
            switch self {
            case .couldNotFoundConfig(let url):
                return "Barca.toml is not found on \(url.path)"
            case .couldNotFoundResolvedCartfile(let url):
                return "Cartfile.resolved is not found on \(url.path)"
            case .couldNotFoundPackage(let package):
                return "Package \(package) is not found in this project"
            }
        }
    }

    public init(projectRoot: URL) throws {
        let barcaConfigPath = Path(projectRoot.appendingPathComponent("Barca.toml").path)
        guard barcaConfigPath.exists else {
            throw Error.couldNotFoundConfig(projectRoot)
        }
        config = try configLoader.load(from: barcaConfigPath.url)

        let cartfileResolvedPath = Path(projectRoot.appendingPathComponent("Cartfile.resolved").path)
        guard cartfileResolvedPath.exists else {
            throw Error.couldNotFoundResolvedCartfile(projectRoot)
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

    public func apply() throws -> [String: InjectionResult] {
        return try packages.map { package -> (String, InjectionResult) in
            let result = try inject(for: package)
            return (package.repositoryName, result)
        }
        .reduce(into: [:]) { (dictionary, result) in
            let (repositoryName, injectionResult) = result
            dictionary[repositoryName] = injectionResult
        }
    }

    func inject(for package: Package) throws -> InjectionResult {
        let repository = config.packages[dynamicMember: package.repositoryName]
        guard let targets = repository?.targets else {
            return [:]
        }
        return try targets.map { target -> (String, FrameworkType?) in
            let result = try injector.inject(target.type, into: target.name, of: package)
            return (target.name, result)
        }
        .reduce(into: [:]) { (dictionary, result) in
            let (targetName, frameworkType) = result
            dictionary[targetName] = frameworkType
        }
    }

    public enum CleanTarget {
        case all
        case package(String)
    }

    public func clean(_ target: CleanTarget) throws {
        let cleaner = PackageCleaner(shell: Shell(),
                                     gitURL: config.gitURL ?? defaultGitURL)
        switch target {
        case .all:
            for package in packages {
                try cleaner.clean(package.repositoryPath)
            }
        case .package(let repositoryName):
            guard let package = packages.first(where: { $0.repositoryName ==  repositoryName}) else {
                throw Error.couldNotFoundPackage(repositoryName)
            }
            try cleaner.clean(package.repositoryPath)
        }
    }
}
