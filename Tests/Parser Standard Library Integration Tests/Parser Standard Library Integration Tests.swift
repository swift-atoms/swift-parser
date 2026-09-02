import Parser
import Parser_Standard_Library_Integration
import Parser_Sequence
import Testing

@Suite
struct `Parser Standard Library Integration` {

    @Test
    func `String parses a matching prefix`() throws(any Swift.Error) {
        var input: Substring = "swift-parser"

        try "swift".parse(&input)

        #expect(input == "-parser")
    }

    @Test
    func `Optional Parser parses a present parser`() throws(any Swift.Error) {
        let parser = Swift.Optional<String>.Parser("swift")
        var input: Substring = "swift-parser"

        let output: Void? = try parser.parse(&input)

        #expect(output != nil)
        #expect(input == "-parser")
    }

    @Test
    func `Optional Parser skips an absent parser`() throws(any Swift.Error) {
        let parser = Swift.Optional<String>.Parser(nil)
        var input: Substring = "swift-parser"

        let output: Void? = try parser.parse(&input)

        #expect(output == nil)
        #expect(input == "swift-parser")
    }

    @Test
    func `a Sequence block uses Swift Optional Parser for buildIf`() throws(any Swift.Error) {
        let includePrefix = true
        let parser = Parser.Sequence(Substring.self) {
            if includePrefix {
                "swift"
            }
        }
        var input: Substring = "swift-parser"

        let output: Void? = try parser.parse(&input)

        #expect(output != nil)
        #expect(input == "-parser")
    }

    @Test
    func `a body uses Swift Optional Parser for buildIf`() throws(any Swift.Error) {
        let parser = OptionalPrefix(includePrefix: true)
        var input: Substring = "swift-parser"

        let output: Void? = try parser.parse(&input)

        #expect(output != nil)
        #expect(input == "-parser")
    }

    @Test
    func `a body omits an absent buildIf element`() throws(any Swift.Error) {
        let parser = OptionalPrefix(includePrefix: false)
        var input: Substring = "swift-parser"

        let output: Void? = try parser.parse(&input)

        #expect(output == nil)
        #expect(input == "swift-parser")
    }
}

private struct OptionalPrefix: Parser.`Protocol` {
    typealias Input = Substring
    typealias Output = Void?
    typealias Failure = String.Failure

    let includePrefix: Bool

    var body: Swift.Optional<String>.Parser {
        if includePrefix {
            "swift"
        }
    }
}
