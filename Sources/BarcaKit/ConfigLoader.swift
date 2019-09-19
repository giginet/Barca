import Foundation
import TOMLDecoder

struct Config: Decodable {
    var repositories: [Repository]
    
    struct Repository: Decodable {
        var name: String
        var targets: [Target]

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
    
    func loader(from data: Data) throws -> Config {
        try decoder.decode(Config.self, from: data)
    }
}
