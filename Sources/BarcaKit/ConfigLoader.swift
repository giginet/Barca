import Foundation
import TOMLDecoder

private struct InnerConfig: Decodable {
    var repository: [String: [String: FrameworkType]]
}

struct Config: Decodable {
    private(set) var repositories: RepositoryContainer
    
    fileprivate init(_ innerConfig: InnerConfig) {
        let repositories = Set(innerConfig.repository.map { (repositoryName, targetMap) -> Repository in
            let targets = Set(targetMap.map { (targetName, frameworkType) -> Repository.Target in
                return Repository.Target(name: targetName, type: frameworkType)
            })
            return Repository(name: repositoryName, targets: targets)
        })
        self.repositories = RepositoryContainer(repositories: repositories)
    }
    
    @dynamicMemberLookup
    struct RepositoryContainer: Decodable {
        fileprivate var repositories: Set<Repository>
        
        subscript(dynamicMember name: String) -> Repository? {
            return repositories.first { $0.name == name }
        }
    }
    
    @dynamicMemberLookup
    struct Repository: Decodable, Hashable {
        var name: String
        var targets: Set<Target>
        
        subscript(dynamicMember name: String) -> FrameworkType? {
            return targets.first { $0.name == name }?.type
        }
        
        struct Target: Decodable, Hashable {
            var name: String
            var type: FrameworkType
        }
    }
}

struct ConfigLoader {
    private let decoder: TOMLDecoder = {
        let decoder = TOMLDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    func load(from url: URL) throws -> Config {
        let data = try Data(contentsOf: url)
        return try load(data)
    }
    
    func load(_ data: Data) throws -> Config {
        let innerConfig = try decoder.decode(InnerConfig.self, from: data)
        return Config(innerConfig)
    }
}
