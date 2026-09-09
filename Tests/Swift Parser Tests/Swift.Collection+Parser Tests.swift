import Parser
import Testing

@Suite
struct `Swift.Collection+Parser Tests` {
    @Test
    func `an arbitrary collection works as a literal`() throws {
        var input: ArraySlice<Int> = [1, 2, 3, 4]
        try Parser { 1...3 }.parse(&input)
        #expect(input == [4])
    }

    @Test
    func `a collection factory selects its input explicitly`() throws {
        var input: Substring = "swift!"
        try Array("swift").parser(for: Substring.self).parse(&input)
        #expect(input == "!")
    }

    @Test
    func `a generic collection mismatch preserves input`() {
        var input: ArraySlice<Int> = [1, 9, 3]
        #expect(throws: Swift.Slice<ClosedRange<Int>>.Parser<ArraySlice<Int>>.Error.mismatch) {
            try Parser { 1...3 }.parse(&input)
        }
        #expect(input == [1, 9, 3])
    }
}
