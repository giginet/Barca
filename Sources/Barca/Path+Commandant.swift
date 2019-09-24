import Foundation
import Commandant
import PathKit

extension Path: ArgumentProtocol {
    public static var name: String {
        return "path"
    }

    public static func from(string: String) -> Path? {
        return .init(string)
    }

}
