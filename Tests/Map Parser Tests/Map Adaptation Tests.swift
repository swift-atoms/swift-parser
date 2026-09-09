#if Map && Append && Skip && FlatMap
import Map
import Parser
import Testing

@Suite
struct `Map adapts to parsing` {
    @Test
    func `the same transformation can be used directly and as a parser`() {
        let map = Map::Map<Int, String, Never> { String($0) }
        let parser = map.parser(Parser<Int, Int, Never> { input in
            input += 1
            return input
        })
        var input = 41
        #expect(map(42) == "42")
        #expect(parser.parse(&input) == "42")
        #expect(input == 42)
    }

}

#endif
