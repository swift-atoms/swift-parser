#if IteratorLeaves && Pair && Either
import Iterator
import Parser
import Parser
import Testing

@Suite
struct `Swift.Array+Parser Tests` {

    @Test
    func `an array parses itself from the input`() throws(any Swift.Error) {
        var input = Characters("swift-parser")

        try prefix(Array("swift")).parse(&input)

        #expect(input.remainder == "-parser")
    }

    @Test
    func `an array reports a mismatch`() {
        var input = Characters("swim")

        #expect(throws: Parser::ConsumingLiteral<Characters>.Error.mismatch) {
            try prefix(Array("swift")).parse(&input)
        }
    }

    @Test
    func `an array reports the end of input as a short match`() {
        var input = Characters("sw")

        #expect(throws: Parser::ConsumingLiteral<Characters>.Error.mismatch) {
            try prefix(Array("swift")).parse(&input)
        }
    }

    @Test
    func `an empty array matches without consuming`() throws(any Swift.Error) {
        var input = Characters("swift")

        try prefix([]).parse(&input)

        #expect(input.remainder == "swift")
    }

    @Test
    func `a Parser block lifts an array literal`() throws(any Swift.Error) {
        let parser = Parser::Parser {
            Parser::ConsumingLiteral<Characters>(Array("swift"))
            Parser::ConsumingLiteral<Characters>(Array("-"))
        }
        var input = Characters("swift-parser")

        try parser.parse(&input)

        #expect(input.remainder == "parser")
    }

    @Test
    func `a body lifts an array under buildIf`() throws(any Swift.Error) {
        var present = Characters("swift-parser")
        let included: Void? = try OptionalPrefix(includePrefix: true).parse(&present)
        #expect(included != nil)
        #expect(present.remainder == "-parser")

        var absent = Characters("swift-parser")
        let omitted: Void? = try OptionalPrefix(includePrefix: false).parse(&absent)
        #expect(omitted == nil)
        #expect(absent.remainder == "swift-parser")
    }
}

private struct Characters: Iterator.`Protocol` {
    var remainder: Substring

    init(_ text: String) {
        remainder = text[...]
    }

    mutating func next() -> Character? {
        remainder.popFirst()
    }
}

private struct OptionalPrefix: Parsing {
    typealias Input = Characters
    typealias Output = Void?
    typealias Failure = Parser::ConsumingLiteral<Characters>.Error

    let includePrefix: Bool

    var body: some Parsing<Characters, Void?, Failure> {
        if includePrefix {
            Parser::ConsumingLiteral<Characters>(Array("swift"))
        }
    }
}

@Builder<Characters>
private func prefix(_ elements: [Character]) -> Parser::ConsumingLiteral<Characters> {
    Parser::ConsumingLiteral<Characters>(elements)
}
#endif
