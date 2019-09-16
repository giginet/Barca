import Foundation

struct Cartfile {
    typealias Slug = String
    
    struct Package: Hashable {
        enum Source: Hashable {
            case git(URL)
            case github(Slug)
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .git(let url):
                    hasher.combine(url)
                case .github(let slug):
                    hasher.combine(slug)
                }
            }
        }
        var source: Source
        var version: String
    }
    
    var packages: Set<Package>
}

class CartfileParser {
    enum Error: Swift.Error {
        case localURL
        case couldNotLoad(URL)
        case couldNotParse(reason: String)
        
        var localizedDescription: String {
            switch self {
            case .localURL:
                return "Passing URL must be local file URL"
            case .couldNotLoad(let url):
                return "Could not load Cartfile.resolved on \(url)"
            case .couldNotParse(let reason):
                return "Could not parse Cartfile.resolved due to \(reason)"
            }
        }
    }
    
    init() { }
    
    func parse(cartfileResolvedURL: URL) throws -> Cartfile {
        guard cartfileResolvedURL.isFileURL else {
            throw Error.localURL
        }
        guard let content = try? String(contentsOf: cartfileResolvedURL, encoding: .utf8) else {
            throw Error.couldNotLoad(cartfileResolvedURL)
        }
        return try parse(content: content)
    }
    
    func parse(content: String) throws -> Cartfile {
        let declarations = content.split(separator: "\n").map(String.init)
        let packages = Set(declarations.compactMap { try? parseLine($0) })
        return Cartfile(packages: packages)
    }
    
    func parseLine(_ declaration: String) throws -> Cartfile.Package {
        let components = declaration.split(separator: " ")
        guard components.count == 3 else {
            throw Error.couldNotParse(reason: "Dependency declaration must be '<source> <location> <version>'.")
        }
        let sourceString = String(components[0])
        let location = String(components[1])
        let version = String(components[2])
        
        let source: Cartfile.Package.Source
        switch sourceString {
        case "git":
            guard let url = URL(string: location.unquoted()) else {
                throw Error.couldNotParse(reason: "Location \(location) is invalid")
            }
            source = .git(url)
        case "github":
            guard location.split(separator: "/").count == 2 else {
                throw Error.couldNotParse(reason: "GitHub slug \(location) is invalid format")
            }
            source = .github(location.unquoted())
        default:
            throw Error.couldNotParse(reason: "Unknown source \(sourceString)")
        }
        let trimmedVersion = version.unquoted()
        
        return Cartfile.Package(source: source, version: trimmedVersion)
    }
}

extension String {
    fileprivate func unquoted() -> String {
        if isQuoted {
            return String(self[index(after: startIndex)...index(endIndex, offsetBy: -2)])
        }
        return self
    }
}
