#if Prefix && Iterator && Collection
import Parser
import Prefix
import Testing

@Suite
struct `Prefix.Through.Parser Tests` {
    @Test
    func `a builder selects and consumes a prefix`() throws {
        var input: Substring = "abc--def"
        let output = try Parser { Prefix.Through("--") }.parse(&input)
        #expect(output == "abc--")
        #expect(input == "def")
    }

    @Test
    func `failure leaves the original input intact`() {
        var input: Substring = "abc-"
        #expect(throws: Prefix.Through<String>.Error.delimiterNotFound) {
            _ = try Parser { Prefix.Through("--") }.parse(&input)
        }
        #expect(input == "abc-")
    }
}

#endif
