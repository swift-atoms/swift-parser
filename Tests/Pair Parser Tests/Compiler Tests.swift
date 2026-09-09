#if Pair && Append && Skip && Map && FlatMap
import Parser_Test_Support
import Testing

@Suite
private struct `Pair parser ownership constraints survive module emission` {

    @Test
    func `transferring a Pair of owners into a parser prevents its reuse`() throws {
        let diagnostic = try Compiler.emissionFailure(named: "Consumed Pair Owner.swift", in: "Pair")
        #expect(diagnostic.contains("'owners' used after consume"))
    }

    @Test
    func `a Pair parser with noncopyable stored owners cannot be copied`() throws {
        let diagnostic = try Compiler.emissionFailure(named: "Noncopyable Pair Copyability.swift", in: "Pair")
        #expect(diagnostic.contains("requireCopyable"))
        #expect(diagnostic.contains("'Linear' conform to 'Copyable'"))
    }
}
#endif
