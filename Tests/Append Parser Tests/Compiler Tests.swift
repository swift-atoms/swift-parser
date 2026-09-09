#if Append
import Parser_Test_Support
import Testing

@Suite
private struct `Append parser compiler contracts` {

    @Test
    func `transferring an owner into append prevents its reuse`() throws {
        let diagnostic = try Compiler.emissionFailure(named: "Consumed Append Owner.swift", in: "Append")
        #expect(diagnostic.contains("'owner' used after consume"))
    }

    @Test(arguments: ["Noncopyable Append Copyability.swift"])
    func `sequential wrappers with noncopyable stored owners cannot be copied`(_ fixture: String) throws {
        let diagnostic = try Compiler.emissionFailure(named: fixture, in: "Append")
        #expect(diagnostic.contains("requireCopyable"))
        #expect(diagnostic.contains("'Linear' conform to 'Copyable'"))
    }

    @Test(arguments: ["Escaping Append Accumulated.swift", "Escaping Append Next.swift"])
    func `append results cannot outlive either operand backing storage`(_ fixture: String) throws {
        let diagnostic = try Compiler.emissionFailure(named: fixture, in: "Append")
        #expect(diagnostic.contains("lifetime-dependent value escapes its scope"))
    }

    @Test
    func `append adapters retain noncopyable parser ownership`() throws {
        let diagnostic = try Compiler.emissionFailure(named: "Noncopyable Append Adapter.swift", in: "Append")
        #expect(diagnostic.contains("requireCopyable"))
        #expect(diagnostic.contains("'Linear' conform to 'Copyable'"))
    }
}
#endif
