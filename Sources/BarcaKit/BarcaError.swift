import Foundation

public protocol BarcaError: Error {
    var description: String { get }
}

public struct FrontendError: BarcaError {
    var innerError: Error

    public init(_ error: Error) {
        self.innerError = error
    }

    public var description: String {
        switch innerError {
        case let barcaError as BarcaError:
            return barcaError.description
        default:
            return innerError.localizedDescription
        }
    }
}
