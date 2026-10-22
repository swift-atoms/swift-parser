#if Product
    import Foundation
    import Parser
    import Testing

    @Suite
    struct `Product Parser Compiler Tests` {

        @Test
        func `intended API remains gated without noncopyable packs`() {
            #if hasFeature(NoncopyablePacks)
                Issue.record("Remove the compiler gate and activate Product.Parser")
            #else
                #expect(Bool(true))
            #endif
        }

        @Test
        func `parameter packs cannot yet suppress element capabilities`() throws {
            let diagnostic = try typecheckFailure(
                named: "Noncopyable Parameter Pack.swift"
            )

            #expect(diagnostic.contains("cannot suppress '~Copyable'"))
            #expect(diagnostic.contains("cannot suppress '~Escapable'"))
            #expect(diagnostic.contains("each Element"))
        }

        private func typecheckFailure(named name: String) throws -> String {
            let fixture = Bundle.module.resourceURL!
                .appendingPathComponent("Fixtures")
                .appendingPathComponent(name)
            let process = Process()
            let standardError = Pipe()
            #if os(macOS)
                process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
                let launcher = ["swiftc"]
            #elseif os(Windows)
                let command = try #require(ProcessInfo.processInfo.environment["ComSpec"])
                process.executableURL = URL(fileURLWithPath: command)
                let launcher = ["/d", "/c", "swiftc"]
            #else
                process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
                let launcher = ["swiftc"]
            #endif
            process.arguments =
                launcher + [
                    "-typecheck",
                    "-D", "Product",
                    "-swift-version", "6",
                    "-enable-experimental-feature", "Lifetimes",
                    "-enable-experimental-feature", "MoveOnlyTuples",
                    "-module-name", "ProductParserCapabilityProof",
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
            return diagnostic
        }
    }
#endif
