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
    func `stored transform result must be escapable`() throws {
        let diagnostic = try emissionFailure(
            named: "Nonescapable Transform Result.swift"
        )

        #expect(
            diagnostic.contains(
                "candidate requires that 'ScopedResult' conform to 'Escapable'"
            )
        )
    }

    @Test
    func `linear flat map owners compose over scoped input through the public API`() throws {
        let result = try emitFixture(named: "Linear FlatMap Composition.swift")
        #expect(result.status == 0, "\(result.diagnostic)")
    }

    @Test(arguments: ["Consumed Direct FlatMap Upstream.swift", "Consumed Fluent FlatMap Upstream.swift"])
    func `transferring an upstream owner prevents its reuse`(_ fixture: String) throws {
        let diagnostic = try emissionFailure(named: fixture)
        #expect(diagnostic.contains("'upstream' used after consume"))
    }

    @Test
    func `flat map results must remain escapable`() throws {
        let diagnostic = try emissionFailure(named: "Nonescapable FlatMap Result.swift")
        #expect(diagnostic.contains("'ScopedResult' conform to 'Escapable'"))
    }

    @Test
    func `a flat map with a noncopyable stored upstream cannot be copied`() throws {
        let diagnostic = try emissionFailure(named: "Noncopyable FlatMap Copyability.swift")
        #expect(diagnostic.contains("requireCopyable"))
        #expect(diagnostic.contains("'Owned' conform to 'Copyable'"))
    }

    @Test
    func `a sequence builder cannot consume an owner captured from outside`() throws {
        let diagnostic = try emissionFailure(named: "Captured Sequence Owner.swift")
        #expect(diagnostic.contains("noncopyable 'owner' cannot be consumed when captured"))
    }

    @Test
    func `transferring an owner into append prevents its reuse`() throws {
        let diagnostic = try emissionFailure(named: "Consumed Append Owner.swift")
        #expect(diagnostic.contains("'owner' used after consume"))
    }

    @Test(arguments: ["Noncopyable Sequence Copyability.swift", "Noncopyable Append Copyability.swift"])
    func `sequential wrappers with noncopyable stored owners cannot be copied`(_ fixture: String) throws {
        let diagnostic = try emissionFailure(named: fixture)
        #expect(diagnostic.contains("requireCopyable"))
        #expect(diagnostic.contains("'Linear' conform to 'Copyable'"))
    }

    @Test(arguments: ["Escaping Append Accumulated.swift", "Escaping Append Next.swift"])
    func `append results cannot outlive either operand backing storage`(_ fixture: String) throws {
        let diagnostic = try emissionFailure(named: fixture)
        #expect(diagnostic.contains("lifetime-dependent value escapes its scope"))
    }

    @Test
    func `append adapters retain noncopyable parser ownership`() throws {
        let diagnostic = try emissionFailure(named: "Noncopyable Append Adapter.swift")
        #expect(diagnostic.contains("requireCopyable"))
        #expect(diagnostic.contains("'Linear' conform to 'Copyable'"))
    }

    @Test
    func `mapping a failure transfers the upstream owner`() throws {
        let diagnostic = try emissionFailure(named: "Consumed Error Map Owner.swift")
        #expect(diagnostic.contains("'owner' used after consume"))
    }

    @Test
    func `failure mapping cannot copy a noncopyable upstream`() throws {
        let diagnostic = try emissionFailure(named: "Noncopyable Error Map Copyability.swift")
        #expect(diagnostic.contains("requireCopyable"))
        #expect(diagnostic.contains("'Owned' conform to 'Copyable'"))
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
