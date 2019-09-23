import Foundation
import struct XcodeProj.BuildSettings

public enum FrameworkType: String, Decodable {
    case `static`
    case dynamic
    
    fileprivate init?(configurationValue: String) {
        switch configurationValue {
        case "staticlib":
            self = .static
        case "mh_dylib":
            self = .dynamic
        default:
            return nil
        }
    }

    var configurationValue: String {
        switch self {
        case .static:
            return "staticlib"
        case .dynamic:
            return "mh_dylib"
        }
    }
}

extension BuildSettings {
    public var frameworkType: FrameworkType? {
        guard let machOType = self["MACH_O_TYPE"] as? String else {
            return .static
        }
        return FrameworkType(configurationValue: machOType)
    }
}
