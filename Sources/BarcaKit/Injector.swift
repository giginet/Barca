import Foundation
import PathKit
import XcodeProj

struct Injector {
    enum Error: BarcaError {
        case couldNotFoundTarget(String)
        
        var description: String {
            switch self {
            case .couldNotFoundTarget(let targetName):
                return "Target \"\(targetName)\" is not found in this project."
            }
        }
    }
    
    init() { }
    
    func inject(_ frameworkType: FrameworkType, into targetName: String, of package: Package) throws -> FrameworkType? {
        guard let target = package.targets.first(where: { $0.name == targetName }) else {
            throw Error.couldNotFoundTarget(targetName)
        }
        let allConfigurations = target.buildConfigurationList?.buildConfigurations ?? []
        for configuration in allConfigurations {
            configuration.buildSettings["MACH_O_TYPE"] = frameworkType.configurationValue
        }
        let xcodeProj = package.xcodeProj
        do {
            try xcodeProj.write(pathString: package.repositoryPath.url.path, override: true)
            return frameworkType
        } catch {
            return nil
        }
    }
}
