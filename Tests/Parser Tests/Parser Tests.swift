import Parser
import Testing

@Suite
struct `Parser Protocol Tests` {

    @Test
    func `a leaf declares only parse`() throws(any Swift.Error) {
        var input: Substring = "abc"
        let output = try Literal("a").parse(&input)
        #expect(output == "a")
        #expect(input == "bc")
    }

    @Test
    func `a single element body forwards to that element`() throws(any Swift.Error) {
        var input: Substring = "abc"
        let output = try Wrapped().parse(&input)
        #expect(output == "a")
        #expect(input == "bc")
    }

    @Test
    func `Parseable exposes a static parser`() throws(any Swift.Error) {
        var input: Substring = "abc"
        let output = try Token.parser.parse(&input)
        #expect(output == Token(character: "a"))
    }
}

private enum LiteralError: Swift.Error {
    case expected(Character)
}

private struct Literal: Parser.`Protocol` {
    let expected: Character

    init(_ expected: Character) {
        self.expected = expected
    }

    borrowing func parse(_ input: inout Substring) throws(LiteralError) -> Character {
        guard input.first == expected else { throw .expected(expected) }
        input = input.dropFirst()
        return expected
    }
}

private struct Wrapped: Parser.`Protocol` {
    typealias Failure = LiteralError

    var body: some Parser.`Protocol`<Substring, Character, LiteralError> {
        Literal("a")
    }
}

private struct Token: Equatable, Parseable {
    let character: Character

    static var parser: TokenParser { TokenParser() }
}

private struct TokenParser: Parser.`Protocol` {
    borrowing func parse(_ input: inout Substring) throws(LiteralError) -> Token {
        guard let character = input.first else { throw .expected(" ") }
        input = input.dropFirst()
        return Token(character: character)
    }
}
