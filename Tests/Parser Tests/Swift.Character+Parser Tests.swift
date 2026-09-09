import Parser
import Testing

@Suite
struct `Swift.Character+Parser Tests` {
    @Test
    func `a literal consumes exactly its matching prefix`() throws {
        var input: Substring = "swift-parser"
        try Parser { Character("s") }.parse(&input)
        #expect(input == "wift-parser")
    }

    @Test
    func `a mismatch leaves input unchanged`() {
        var input: Substring = "other"
        #expect(throws: Swift.Character.Parser.Error.mismatch) {
            try Parser { Character("s") }.parse(&input)
        }
        #expect(input == "other")
    }

    @Test
    func `explicit parser types accept a literal`() throws {
        let parser = Parser<Substring, Void, Swift.Character.Parser.Error> {
            Character("s")
        }
        var input: Substring = "swift-parser"
        try parser.parse(&input)
        #expect(input == "wift-parser")
    }
}
