#if Prefix && Iterator && Collection
import Prefix
import Parser
import Testing

@Suite
struct `Prefix iteration parsing Tests` {
    @Test
    func `a predicate parser materializes a single pass prefix and preserves remainder`() throws {
        var input = "123x".prefixIterator()
        let parser = Prefix.While<Character> { $0.isNumber }.parser(for: type(of: input))
        #expect(try parser.parse(&input) == Array("123"))
        #expect(input.next() == "x")
    }

    @Test
    func `delimiter parsers share their buffered input`() throws {
        var input = "abc--def".prefixIterator()
        let before = Prefix.UpTo("--").parser(for: type(of: input))
        #expect(try before.parse(&input) == Array("abc"))
        let through = Prefix.Through("--").parser(for: type(of: input))
        #expect(try through.parse(&input) == Array("--"))
        let count = Prefix(maximum: 2).parser(for: type(of: input))
        #expect(try count.parse(&input) == Array("de"))
        #expect(input.next() == "f")
    }
}

#endif
