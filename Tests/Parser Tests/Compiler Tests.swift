import Foundation
import Testing

@Suite
private struct `Parser ownership and lifetime constraints survive module emission` {

    @Test(arguments: ["Escaping Parser Input.swift"])
    func `concrete parser results cannot outlive input`(_ fixture: String) throws {
        let diagnostic = try emissionFailure(named: fixture)
        #expect(diagnostic.contains("escapes its scope"), "\(diagnostic)")
    }

    @Test
    func `concrete parser supports scoped input and direct scoped output`() throws {
        let result = try emitFixture(named: "Scoped Parser Construction.swift")
        #expect(result.status == 0, "\(result.diagnostic)")
    }

    @Test
    func `a sequence builder cannot consume an owner captured from outside`() throws {
        let diagnostic = try emissionFailure(named: "Captured Sequence Owner.swift")
        #expect(diagnostic.contains("noncopyable 'owner' cannot be consumed when captured"))
    }

    @Test(arguments: ["Noncopyable Sequence Copyability.swift"])
    func `sequential wrappers with noncopyable stored owners cannot be copied`(_ fixture: String) throws {
        let diagnostic = try emissionFailure(named: fixture)
        #expect(diagnostic.contains("requireCopyable"))
        #expect(diagnostic.contains("'Linear' conform to 'Copyable'"))
    }

    private func emissionFailure(named name: String) throws -> String {
        let result = try emitFixture(named: name)
        try #require(result.status != 0, "Fixture unexpectedly emitted a module")
        return result.diagnostic
    }

    private func emitFixture(named name: String) throws -> (status: Int32, diagnostic: String) {
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
            .appendingPathComponent(name)

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
