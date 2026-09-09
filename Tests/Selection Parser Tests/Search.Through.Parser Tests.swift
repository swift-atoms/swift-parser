#if Search && Repetition && Iterator && Collection
import Parser
import Search
import Repetition
import Cardinal
import Predicate
import Testing

@Suite
struct `Search.Through.Parser Tests` {
    @Test
    func `a builder selects and consumes a prefix`() throws {
        var input: Substring = "abc--def"
        let output = try Parser { Search("--").selecting(.end) }.parse(&input)
        #expect(output == "abc--")
        #expect(input == "def")
    }

    @Test
    func `failure leaves the original input intact`() {
        var input: Substring = "abc-"
        #expect(throws: Search<String>.Error.notFound) {
            _ = try Parser { Search("--").selecting(.end) }.parse(&input)
        }
        #expect(input == "abc-")
    }
}

#endif
