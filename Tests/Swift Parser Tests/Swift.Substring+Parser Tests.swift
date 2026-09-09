import Parser
import Testing

@Suite
struct `Swift.Substring+Parser Tests` {
    @Test
    func `a literal consumes exactly its matching prefix`() throws {
        var input: Substring = "swift-parser"
        try Parser { "swift"[...] }.parse(&input)
        #expect(input == "-parser")
    }

    @Test
    func `a mismatch leaves input unchanged`() {
        var input: Substring = "swim"
        #expect(throws: Swift.Substring.Parser.Error.mismatch) {
            try Parser { "swift"[...] }.parse(&input)
        }
        #expect(input == "swim")
    }

    @Test
    func `explicit parser types accept a literal`() throws {
        let parser = Parser<Substring, Void, Swift.Substring.Parser.Error> {
            "swift"[...]
        }
        var input: Substring = "swift-parser"
        try parser.parse(&input)
        #expect(input == "-parser")
    }

    @Test
    func `an empty literal consumes nothing`() throws {
        var input: Substring = "swift-parser"
        try Parser { ""[...] }.parse(&input)
        #expect(input == "swift-parser")
    }

    @Test
    func `a short input is not partially consumed`() {
        var input: Substring = "sw"
        #expect(throws: Swift.Substring.Parser.Error.mismatch) {
            try Parser { "swift"[...] }.parse(&input)
        }
        #expect(input == "sw")
    }
}
