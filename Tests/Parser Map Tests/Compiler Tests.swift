import Foundation
import Testing

@Suite
private struct `Parser.Map Compiler Tests` {

    @Test
    func `stored transform result must be escapable`() throws {
        let diagnostic = try typecheckFailure(
            named: "Nonescapable Transform Result.swift"
        )

        #expect(
            diagnostic.contains(
                "candidate requires that 'ScopedResult' conform to 'Escapable'"
            )
        )
    }

    private func typecheckFailure(named name: String) throws -> String {
        var products = URL(fileURLWithPath: Bundle.module.bundlePath)
        for _ in 0..<12 {
            let direct = products.appendingPathComponent(
                "Parser_Map.swiftmodule"
            )
            let modules = products
                .appendingPathComponent("Modules")
                .appendingPathComponent("Parser_Map.swiftmodule")
            if FileManager.default.fileExists(atPath: direct.path)
                || FileManager.default.fileExists(atPath: modules.path)
            {
                break
            }
            products.deleteLastPathComponent()
        }

        let direct = products.appendingPathComponent("Parser_Map.swiftmodule")
        let modules = products
            .appendingPathComponent("Modules")
            .appendingPathComponent("Parser_Map.swiftmodule")
        try #require(
            FileManager.default.fileExists(atPath: direct.path)
                || FileManager.default.fileExists(atPath: modules.path)
        )

        let fixture = try #require(Bundle.module.resourceURL)
            .appendingPathComponent("Fixtures")
            .appendingPathComponent(name)

        let process = Process()
        let standardError = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = [
            "swiftc",
            "-typecheck",
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
        process.waitUntilExit()

        let diagnostic = String(
            decoding: standardError.fileHandleForReading.readDataToEndOfFile(),
            as: UTF8.self
        )

        #expect(process.terminationStatus != 0, "Fixture unexpectedly typechecked")
        #expect(!diagnostic.contains("no such module"))
        return diagnostic
    }
}
