#if FlatMap
import FlatMap
import Parser
import Testing

@Suite
struct `FlatMap adapts selected parsers` {
    @Test
    func `an instance adapts its selected parser`() throws {
        let flatMap = FlatMap::FlatMap<Int, Parser<Int, Int, Never>> { seed in
            Parser { input in
                input += 1
                return seed + input
            }
        }
        let parser = flatMap.parser(Parser<Int, Int, Never> { input in
            input += 1
            return input
        })
        var input = 0
        #expect(try parser.parse(&input) == 3)
        #expect(input == 2)
    }

}

#endif
