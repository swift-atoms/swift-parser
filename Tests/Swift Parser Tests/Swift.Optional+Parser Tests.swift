import Parser
import Testing

@Suite
struct `Optional parsers preserve present operations and omit absent body elements` {

    @Test
    func `Optional Parser parses a present parser`() throws(any Swift.Error) {
        let parser = Swift.Optional<Prefix>.Parser(Prefix("swift"))
        var input: Substring = "swift-parser"

        let output: Void? = try parser.parse(&input)

        #expect(output != nil)
        #expect(input == "-parser")
    }

    @Test
    func `a present parser failure is not treated as absence`() {
        var input: Substring = "swim"
        #expect(throws: Mismatch.mismatch) {
            try OptionalPrefix(includePrefix: true).parse(&input)
        }
        #expect(input == "swim")
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
    func `a Parser block uses Swift Optional Parser for buildIf`() throws(any Swift.Error) {
        let includePrefix = true
        let parser = Parser<Substring, Void?, Mismatch> {
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

private typealias Mismatch = Swift.String.Parser.Error

private struct Prefix: Parsing {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    typealias Failure = Mismatch

    var body: some Parsing<Substring, Void, Mismatch> {
        text
    }
}

private struct OptionalPrefix: Parsing {
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
