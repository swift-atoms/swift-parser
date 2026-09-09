#if Map && Append && Skip && FlatMap
import Parser_Test_Support
import Testing

@Suite
private struct `Map parser ownership and lifetime constraints survive module emission` {

    @Test
    func `stored transform result must be escapable`() throws {
        let diagnostic = try Compiler.emissionFailure(named: "Nonescapable Transform Result.swift", in: "Map")

        #expect(
            diagnostic.contains(
                "candidate requires that 'ScopedResult' conform to 'Escapable'"
            )
        )
    }

    @Test
    func `linear flat map owners compose over scoped input through the public API`() throws {
        let result = try Compiler.emitFixture(named: "Linear FlatMap Composition.swift", in: "Map")
        #expect(result.status == 0, "\(result.diagnostic)")
    }

    @Test
    func `mapping a failure transfers the upstream owner`() throws {
        let diagnostic = try Compiler.emissionFailure(named: "Consumed Error Map Owner.swift", in: "Map")
        #expect(diagnostic.contains("'owner' used after consume"))
    }

    @Test
    func `failure mapping cannot copy a noncopyable upstream`() throws {
        let diagnostic = try Compiler.emissionFailure(named: "Noncopyable Error Map Copyability.swift", in: "Map")
        #expect(diagnostic.contains("requireCopyable"))
        #expect(diagnostic.contains("'Owned' conform to 'Copyable'"))
    }
}
#endif
