import Foundation
import Testing

package enum Compiler {
    package static func emissionFailure(named name: String, in group: String = "Parser") throws -> String {
        let result = try emitFixture(named: name, in: group)
        try #require(result.status != 0, "Fixture unexpectedly emitted a module")
        return result.diagnostic
    }

    package static func emitFixture(named name: String, in group: String = "Parser") throws -> (status: Int32, diagnostic: String) {
        var products = URL(fileURLWithPath: Bundle.module.bundlePath)
        for _ in 0..<12 {
            let direct = products.appendingPathComponent(
                "Parser.swiftmodule"
            )
            let modules = products
                .appendingPathComponent("Modules")
                .appendingPathComponent("Parser.swiftmodule")
            if FileManager.default.fileExists(atPath: direct.path)
                || FileManager.default.fileExists(atPath: modules.path)
            {
                break
            }
            products.deleteLastPathComponent()
        }

        let direct = products.appendingPathComponent("Parser.swiftmodule")
        let modules = products
            .appendingPathComponent("Modules")
            .appendingPathComponent("Parser.swiftmodule")
        try #require(
            FileManager.default.fileExists(atPath: direct.path)
                || FileManager.default.fileExists(atPath: modules.path)
        )

        let fixture = try #require(Bundle.module.resourceURL)
            .appendingPathComponent("Fixtures")
            .appendingPathComponent(group)
            .appendingPathComponent(name)

        try #require(FileManager.default.fileExists(atPath: fixture.path), "Missing compiler fixture: \(group)/\(name)")

        let output = FileManager.default.temporaryDirectory
            .appendingPathComponent("parser-emission-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: output) }

        let process = Process()
        let standardError = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = [
            "swiftc",
            "-emit-module",
            "-emit-module-path", output.appendingPathComponent("Proof.swiftmodule").path,
            "-swift-version", "6",
            "-strict-memory-safety",
            "-enable-experimental-feature", "Lifetimes",
            "-module-name", "Proof",
            "-I", products.path,
            "-I", products.appendingPathComponent("Modules").path,
            fixture.path,
        ]
        process.standardError = standardError
        try process.run()

        let diagnostic = String(
            decoding: standardError.fileHandleForReading.readDataToEndOfFile(),
            as: UTF8.self
        )
        process.waitUntilExit()

        #expect(!diagnostic.contains("no such module"))
        return (process.terminationStatus, diagnostic)
    }
}
