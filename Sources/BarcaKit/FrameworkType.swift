import Foundation

public enum FrameworkType: String, Decodable {
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
