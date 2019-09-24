import Foundation
import PrettyColors

extension String.StringInterpolation {
    public mutating func appendInterpolation(_ value: String,
                                      foregroundColor: Color.Named.Color? = nil,
                                      backgroundColor: Color.Named.Color? = nil) {
        appendLiteral(Color.Wrap(foreground: foregroundColor,
                                 background: backgroundColor).wrap(value))
    }
}
