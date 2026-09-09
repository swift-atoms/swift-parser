#if Search && Repetition && Iterator && Collection
import Parser
import Search
import Repetition
import Cardinal
import Predicate
import Testing

@Suite
struct `Cardinal.Range.Parser Tests` {
    @Test
    func `a builder selects and consumes a prefix`() throws {
        var input: Substring = "abc--def"
        let output = try Parser { (Cardinal(UInt(2))...Cardinal(UInt(2))).parser(for: Substring.self) }.parse(&input)
        #expect(output == "ab")
        #expect(input == "c--def")
    }

    @Test
    func `failure leaves the original input intact`() {
        var input: Substring = "a"
        #expect(throws: Repetition<ClosedRange<Cardinal>, Void>.Error.insufficient(actual: 1)) {
            _ = try Parser { (Cardinal(UInt(2))...Cardinal(UInt(2))).parser(for: Substring.self) }.parse(&input)
        }
        #expect(input == "a")
    }
}

#endif
