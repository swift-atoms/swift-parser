#if FlatMap
import Parser_Test_Support
import Testing

@Suite
private struct `FlatMap parser compiler contracts` {

    @Test(arguments: ["Consumed Direct FlatMap Upstream.swift", "Consumed Fluent FlatMap Upstream.swift"])
    func `transferring an upstream owner prevents its reuse`(_ fixture: String) throws {
        let diagnostic = try Compiler.emissionFailure(named: fixture, in: "FlatMap")
        #expect(diagnostic.contains("'upstream' used after consume"))
    }

    @Test
    func `flat map results must remain escapable`() throws {
        let diagnostic = try Compiler.emissionFailure(named: "Nonescapable FlatMap Result.swift", in: "FlatMap")
        #expect(diagnostic.contains("'ScopedResult' conform to 'Escapable'"))
    }

    @Test
    func `a flat map with a noncopyable stored upstream cannot be copied`() throws {
        let diagnostic = try Compiler.emissionFailure(named: "Noncopyable FlatMap Copyability.swift", in: "FlatMap")
        #expect(diagnostic.contains("requireCopyable"))
        #expect(diagnostic.contains("'Owned' conform to 'Copyable'"))
    }
}
#endif
