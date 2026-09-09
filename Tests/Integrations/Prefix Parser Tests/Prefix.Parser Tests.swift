#if Prefix && Iterator && Collection
import Parser
import Prefix
import Testing

@Suite
struct `Prefix.Parser Tests` {
    @Test
    func `a builder selects and consumes a prefix`() throws {
        var input: Substring = "abc--def"
        let output = try Parser { Prefix(minimum: 2, maximum: 2) }.parse(&input)
        #expect(output == "ab")
        #expect(input == "c--def")
    }

    @Test
    func `failure leaves the original input intact`() {
        var input: Substring = "a"
        #expect(throws: Prefix.Error.insufficientElements(minimum: 2, actual: 1)) {
            _ = try Parser { Prefix(minimum: 2, maximum: 2) }.parse(&input)
        }
        #expect(input == "a")
    }
}

#endif
