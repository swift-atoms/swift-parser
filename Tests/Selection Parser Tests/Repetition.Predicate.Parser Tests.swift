#if Search && Repetition && Iterator && Collection
import Parser
import Search
import Repetition
import Cardinal
import Predicate
import Testing

@Suite
struct `Repetition.Predicate.Parser Tests` {
    @Test
    func `a builder selects and consumes a prefix`() throws {
        var input: Substring = "abc--def"
        let output = try Parser { Repetition((Cardinal(UInt(1))...), operation: Predicate<Character>{ $0 != "-" }).parser(for: Substring.self) }.parse(&input)
        #expect(output == "abc")
        #expect(input == "--def")
    }

    @Test
    func `failure leaves the original input intact`() {
        var input: Substring = "--"
        #expect(throws: Repetition<PartialRangeFrom<Cardinal>, Void>.Error.insufficient(actual: 0)) {
            _ = try Parser { Repetition((Cardinal(UInt(1))...), operation: Predicate<Character>{ $0 != "-" }).parser(for: Substring.self) }.parse(&input)
        }
        #expect(input == "--")
    }
}

#endif
