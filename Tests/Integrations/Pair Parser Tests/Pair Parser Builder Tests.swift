#if Pair && Append && Skip && Map && FlatMap
import Parser
import Either
import Pair
import Testing

@Suite
struct `Pair Parser Builder Tests` {

    @Test
    func `two noncopyable values pair up in order`() throws(any Swift.Error) {
        var input: Substring = "ab"
        let output = try Tokens().parse(&input)
        #expect(output.first.value == "a")
        #expect(output.second.value == "b")
        #expect(input.isEmpty)
    }

    @Test
    func `the first failure is the left branch`() {
        var input: Substring = "xb"
        #expect(throws: Either<Mismatch, Other>.left(.expected("a"))) {
            _ = try MixedTokens().parse(&input)
        }
    }

    @Test
    func `the second failure is the right branch`() {
        var input: Substring = "ax"
        #expect(throws: Either<Mismatch, Other>.right(.expected("b"))) {
            _ = try MixedTokens().parse(&input)
        }
    }

    @Test
    func `equally typed failures collapse`() {
        requireFailure(Tokens(), Mismatch.self)
        requireFailure(ThreeTokens(), Mismatch.self)
    }

    @Test
    func `noncopyable values nest to the left`() throws(any Swift.Error) {
        var input: Substring = "abc"
        let output = try ThreeTokens().parse(&input)
        #expect(output.first.first.value == "a")
        #expect(output.first.second.value == "b")
        #expect(output.second.value == "c")
    }
}

@Suite
struct `Pair Parser Builder Resolution` {

    @Test
    func `copyable values resolve to the atom's Append`() throws(any Swift.Error) {
        let node = Builder<Substring>.buildPartialBlock(accumulated: Literal("a"), next: Literal("b"))
        requireAppend(node)
        var input: Substring = "ab"
        let output = try node.parse(&input)
        #expect(output.0 == "a")
        #expect(output.1 == "b")
    }

    @Test
    func `a noncopyable value resolves to Pair.Parser`() throws(any Swift.Error) {
        let node = Builder<Substring>.buildPartialBlock(accumulated: TokenLiteral("a"), next: Literal("b"))
        requirePair(node)
        var input: Substring = "ab"
        let output = try node.parse(&input)
        #expect(output.first.value == "a")
        #expect(output.second == "b")
    }
}

@Suite
struct `Pair Parser Nonescapable Input` {

    @Test
    func `two noncopyable values pair up from a nonescapable cursor`() throws(any Swift.Error) {
        let bytes: [UInt8] = [3, 4]
        var cursor = Cursor(bytes.span)
        let pair = try TwoBytes().parse(&cursor)
        let end = cursor.index
        #expect(pair.first.value == 3)
        #expect(pair.second.value == 4)
        #expect(end == 2)
    }
}

private func requireFailure<P: Parsing, Failure: Swift.Error>(
    _: borrowing P,
    _: Failure.Type
) where P.Input: ~Copyable & ~Escapable, P.Output: ~Copyable & ~Escapable, P.Failure == Failure {}

private func requireAppend<A: Parsing, N: Parsing, F: Swift.Error, each O>(
    _: borrowing Append::Append<A.Output, N.Output, (repeat each O, N.Output), Never>.Parser<A, N, F>
) where A.Input == N.Input, A.Input: ~Copyable & ~Escapable, N.Input: ~Copyable & ~Escapable, A.Output == (repeat each O) {}

private func requirePair<A: Parsing, N: Parsing, F: Swift.Error>(
    _: borrowing Pair<A, N>.Parser<F>
) where A.Input == N.Input, A.Input: ~Copyable & ~Escapable, N.Input: ~Copyable & ~Escapable, A.Output: ~Copyable & Escapable, N.Output: ~Copyable & Escapable {}

private struct Tokens: Parsing {
    typealias Failure = Mismatch

    var body: some Parsing<Substring, Pair<Token, Token>, Mismatch> {
        TokenLiteral("a")
        TokenLiteral("b")
    }
}

private struct MixedTokens: Parsing {
    typealias Failure = Either<Mismatch, Other>

    var body: some Parsing<Substring, Pair<Token, Token>, Either<Mismatch, Other>> {
        TokenLiteral("a")
        OtherTokenLiteral("b")
    }
}

private struct ThreeTokens: Parsing {
    typealias Failure = Mismatch

    var body: some Parsing<Substring, Pair<Pair<Token, Token>, Token>, Mismatch> {
        TokenLiteral("a")
        TokenLiteral("b")
        TokenLiteral("c")
    }
}

private struct TwoBytes: Parsing {
    typealias Failure = ByteMismatch

    var body: some Parsing<Cursor, Pair<ByteToken, ByteToken>, ByteMismatch> {
        ByteValue()
        ByteValue()
    }
}

private enum Mismatch: Swift.Error, Equatable {
    case expected(Character)
}

private enum Other: Swift.Error, Equatable {
    case expected(Character)
}

private struct Token: ~Copyable {
    let value: Character
}

private struct Literal: Parsing {
    let expected: Character

    init(_ expected: Character) {
        self.expected = expected
    }

    borrowing func parse(_ input: inout Substring) throws(Mismatch) -> Character {
        guard input.first == expected else { throw .expected(expected) }
        input = input.dropFirst()
        return expected
    }
}

private struct TokenLiteral: Parsing {
    let expected: Character

    init(_ expected: Character) {
        self.expected = expected
    }

    borrowing func parse(_ input: inout Substring) throws(Mismatch) -> Token {
        guard input.first == expected else { throw .expected(expected) }
        input = input.dropFirst()
        return Token(value: expected)
    }
}

private struct OtherTokenLiteral: Parsing {
    let expected: Character

    init(_ expected: Character) {
        self.expected = expected
    }

    borrowing func parse(_ input: inout Substring) throws(Other) -> Token {
        guard input.first == expected else { throw .expected(expected) }
        input = input.dropFirst()
        return Token(value: expected)
    }
}

private struct Cursor: ~Escapable {
    var span: Span<UInt8>
    var index: Int

    @_lifetime(copy span)
    init(_ span: Span<UInt8>) {
        self.span = span
        self.index = 0
    }
}

private enum ByteMismatch: Swift.Error, Equatable {
    case endOfInput
}

private struct ByteToken: ~Copyable {
    let value: UInt8
}

private struct ByteValue: Parsing {
    borrowing func parse(_ input: inout Cursor) throws(ByteMismatch) -> ByteToken {
        guard input.index < input.span.count else { throw .endOfInput }
        let byte = input.span[input.index]
        input.index += 1
        return ByteToken(value: byte)
    }
}

#endif
