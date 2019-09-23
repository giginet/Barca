import Foundation

func buildFixtureURL(from fileName: String) -> URL {
    return URL(fileURLWithPath: #file)
        .deletingLastPathComponent()
        .appendingPathComponent("../../Fixtures")
        .appendingPathComponent(fileName)
}
