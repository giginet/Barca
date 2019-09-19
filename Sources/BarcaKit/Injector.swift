import Foundation
import PathKit
import XcodeProj

struct Injector {
    enum FrameworkType: String {
        case `static`
        case dynamic
        
        var configurationValue: String {
            switch self {
            case .static:
                return "staticlib"
            case .dynamic:
                return "mh_dylib"
            }
        }
    }
    
    enum Error: Swift.Error {
        case couldNotFoundTarget(String)
    }
    
    init() { }
    
    func inject(_ frameworkType: FrameworkType, into targetName: String, of package: Package) throws {
        guard let target = package.targets.first(where: { $0.name == targetName }) else {
            throw Error.couldNotFoundTarget(targetName)
        }
        let allConfigurations = target.buildConfigurationList?.buildConfigurations ?? []
        for configuration in allConfigurations {
            configuration.buildSettings["MACH_O_TYPE"] = frameworkType.rawValue
        }
        let xcodeProj = package.xcodeProj
        try xcodeProj.write(pathString: package.repositoryPath.url.path, override: true)
    }
    
}
