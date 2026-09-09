import Parser
import Testing

@Suite
struct `Swift.Slice+Parser Tests` {
    @Test
    func `a slice matches only its selected bounds`() throws {
        let literal = Slice(base: [0, 1, 2, 9], bounds: 1..<3)
        var input: ArraySlice<Int> = [1, 2, 3]
        try Swift.Slice<[Int]>.Parser<ArraySlice<Int>>(literal).parse(&input)
        #expect(input == [3])
    }
}
