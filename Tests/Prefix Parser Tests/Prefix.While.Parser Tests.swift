#if Prefix && Iterator && Collection
import Parser
import Prefix
import Testing

@Suite
struct `Prefix.While.Parser Tests` {
    @Test
    func `a builder selects and consumes a prefix`() throws {
        var input: Substring = "abc--def"
        let output = try Parser { Prefix.While<Character>(minimum: 1) { $0 != "-" } }.parse(&input)
        #expect(output == "abc")
        #expect(input == "--def")
    }

    @Test
    func `failure leaves the original input intact`() {
        var input: Substring = "--"
        #expect(throws: Prefix.Error.insufficientElements(minimum: 1, actual: 0)) {
            _ = try Parser { Prefix.While<Character>(minimum: 1) { $0 != "-" } }.parse(&input)
        }
        #expect(input == "--")
    }
}

#endif
