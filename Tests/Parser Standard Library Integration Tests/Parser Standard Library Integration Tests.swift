import Parser
import Parser_Sequence
import Parser_Standard_Library_Integration
import Testing

@Suite
struct `Parser Standard Library Integration` {

    @Test
    func `Optional Parser parses a present parser`() throws(any Swift.Error) {
        let parser = Swift.Optional<Prefix>.Parser(Prefix("swift"))
        var input: Substring = "swift-parser"

        let output: Void? = try parser.parse(&input)

        #expect(output != nil)
        #expect(input == "-parser")
    }

    @Test
    func `Optional Parser skips an absent parser`() throws(any Swift.Error) {
        let parser = Swift.Optional<Prefix>.Parser(nil)
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
                Prefix("swift")
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

private enum Mismatch: Swift.Error, Equatable {
    case mismatch
}

private struct Prefix: Parser.`Protocol` {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    func parse(_ input: inout Substring) throws(Mismatch) {
        guard input.hasPrefix(text) else { throw .mismatch }
        input = input.dropFirst(text.count)
    }
}

private struct OptionalPrefix: Parser.`Protocol` {
    typealias Input = Substring
    typealias Output = Void?
    typealias Failure = Mismatch

    let includePrefix: Bool

    var body: Swift.Optional<Prefix>.Parser {
        if includePrefix {
            Prefix("swift")
        }
    }
}
