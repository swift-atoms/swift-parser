#if Tagged
import Parser
import Testing

@Suite
struct `Tagged Parser` {

    @Test
    func `an explicit parser lifts its output through the tag`() throws(any Swift.Error) {
        var input: Substring = "abc"

        let value = try Tagged::Tagged<Field, Token>.Parser(TokenParser()).parse(&input)

        #expect(value.underlying == Token(character: "a"))
        #expect(input == "bc")
    }
}

private enum Field {}

private struct Token: Equatable {
    let character: Character
}

private enum TokenError: Error, Equatable {
    case empty
}

private struct TokenParser: Parser::Parsing {
    public var body: Never {
        borrowing get {
            return fatalError("\(Self.self) is a leaf: implement its conformance requirements directly")
        }
    }

    typealias Input = Substring
    typealias Output = Token
    typealias Failure = TokenError

    func parse(_ input: inout Substring) throws(TokenError) -> Token {
        guard let character = input.first else { throw .empty }
        input = input.dropFirst()
        return Token(character: character)
    }
}

extension `Tagged Parser` {

    @Test
    func `the tag surfaces the underlying parser's failure unchanged`() {
        var input: Substring = ""
        #expect(throws: TokenError.empty) {
            try Tagged::Tagged<Field, Token>.Parser(TokenParser()).parse(&input)
        }
        requireFailure(Tagged::Tagged<Field, Token>.Parser(TokenParser()), TokenError.self)
    }
}

private func requireFailure<P: Parser::Parsing, Failure: Swift.Error>(
    _: borrowing P,
    _: Failure.Type
) where P.Input: ~Copyable & ~Escapable, P.Output: ~Copyable & ~Escapable, P.Failure == Failure {}
#endif
