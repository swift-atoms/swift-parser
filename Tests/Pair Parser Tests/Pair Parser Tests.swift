#if Pair && Append && Skip && Map && FlatMap
import Parser
import Either
import Pair
import Testing

@Suite
struct `Pair Parser Tests` {

    @Test
    func `parses sequentially into a nominal Pair`() throws(any Swift.Error) {
        var input: Substring = "abc"
        let parser: Pair::Pair<Literal, OtherLiteral>.Parser<Either<LiteralError, OtherError>> =
            Pair::Pair(Literal("a"), OtherLiteral("b")).parser()

        let output = try parser.parse(&input)

        #expect(output.first == "a")
        #expect(output.second == "b")
        #expect(input == "c")
    }

    @Test
    func `attributes first failure to Either left`() {
        var input: Substring = "xbc"
        let parser: Pair::Pair<Literal, OtherLiteral>.Parser<Either<LiteralError, OtherError>> =
            Pair::Pair(Literal("a"), OtherLiteral("b")).parser()

        #expect(throws: Either<LiteralError, OtherError>.left(.expected("a"))) {
            try parser.parse(&input)
        }
    }

    @Test
    func `attributes second failure to Either right`() {
        var input: Substring = "axc"
        let parser: Pair::Pair<Literal, OtherLiteral>.Parser<Either<LiteralError, OtherError>> =
            Pair::Pair(Literal("a"), OtherLiteral("b")).parser()

        #expect(throws: Either<LiteralError, OtherError>.right(.expected("b"))) {
            try parser.parse(&input)
        }
        #expect(input == "xc")
    }

    @Test
    func `equally typed failures collapse`() throws(any Swift.Error) {
        var input: Substring = "abc"
        let parser: Pair::Pair<Literal, Literal>.Parser<LiteralError> =
            Pair::Pair(Literal("a"), Literal("b")).parser()

        let output = try parser.parse(&input)

        #expect(output.first == "a")
        #expect(output.second == "b")
        #expect(input == "c")
    }

    @Test
    func `noncopyable parsers produce move-only nominal Pair output`() throws(any Swift.Error) {
        var input: Substring = "abc"
        let parser: Pair::Pair<TokenLiteral, TokenLiteral>.Parser<LiteralError> = Pair::Pair(
            TokenLiteral(expected: "a"),
            TokenLiteral(expected: "b")
        ).parser()

        let output = try parser.parse(&input)

        #expect(output.first.value == "a")
        #expect(output.second.value == "b")
        #expect(input == "c")
    }
}

private struct Token: ~Copyable {
    let value: Character
}

private struct TokenLiteral: Parser::Parsing {
    let expected: Character

    borrowing func parse(_ input: inout Substring) throws(LiteralError) -> Token {
        guard input.first == expected else { throw .expected(expected) }
        input = input.dropFirst()
        return Token(value: expected)
    }
}

private enum LiteralError: Error, Equatable {
    case expected(Character)
}

private enum OtherError: Error, Equatable {
    case expected(Character)
}

private struct Literal: Parser::Parsing {
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

private struct OtherLiteral: Parser::Parsing {
    let expected: Character

    init(_ expected: Character) {
        self.expected = expected
    }

    borrowing func parse(_ input: inout Substring) throws(OtherError) -> Character {
        guard input.first == expected else { throw .expected(expected) }
        input = input.dropFirst()
        return expected
    }
}

#endif
