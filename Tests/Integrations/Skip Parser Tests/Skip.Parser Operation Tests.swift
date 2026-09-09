#if Skip && Append && Skip && Map && FlatMap
import Skip
import Parser
import Testing

@Suite
struct `Skip parser operation` {
    @Test
    func `its adapter executes both parsers and discards the second result`() {
        let skip = Skip::Skip<Int, Int>()
        let number = Parser<Int, Int, Never> { input in
            input += 1
            return input
        }
        let parser = skip.parser(number, number)
        var input = 0
        #expect(parser.parse(&input) == 1)
        #expect(input == 2)
    }

}

#endif
