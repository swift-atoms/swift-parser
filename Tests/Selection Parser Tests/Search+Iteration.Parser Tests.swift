#if Search && Repetition && Iterator && Collection
import Search
import Repetition
import Cardinal
import Predicate
import Parser
import Testing

@Suite
struct `Prefix iteration parsing Tests` {
    @Test
    func `a predicate parser materializes a single pass prefix and preserves remainder`() throws {
        var input = "123x".bufferedIterator()
        let parser = Repetition((Cardinal.zero...), operation: Predicate<Character>{ $0.isNumber }).parser(for: type(of: input))
        #expect(try parser.parse(&input) == Array("123"))
        #expect(input.next() == "x")
    }

    @Test
    func `delimiter parsers share their buffered input`() throws {
        var input = "abc--def".bufferedIterator()
        let before = Search("--").selecting(.start).parser(for: type(of: input))
        #expect(try before.parse(&input) == Array("abc"))
        let through = Search("--").selecting(.end).parser(for: type(of: input))
        #expect(try through.parse(&input) == Array("--"))
        let count = (Cardinal.zero...Cardinal(UInt(2))).parser(for: type(of: input))
        #expect(try count.parse(&input) == Array("de"))
        #expect(input.next() == "f")
    }
}

#endif
