import Either
import Pair
import Parser
import Parser_Map
import Parser_Product
import Parser_Skip
import Parser_Sequence
import Testing

@Suite
struct `Parser.Product` {

    @Test
    func `two value elements pair up in order`() throws(any Swift.Error) {
        var input: Substring = "ab"
        let output = try TwoLiterals().parse(&input)
        #expect(output.first == "a")
        #expect(output.second == "b")
        #expect(input.isEmpty)
    }

    @Test
    func `the first failure is the left branch`() {
        var input: Substring = "xb"
        #expect(throws: Either<Mismatch, Other>.left(.expected("a"))) {
            try MixedLiterals().parse(&input)
        }
    }

    @Test
    func `the second failure is the right branch`() {
        var input: Substring = "ax"
        #expect(throws: Either<Mismatch, Other>.right(.expected("b"))) {
            try MixedLiterals().parse(&input)
        }
    }

    @Test
    func `equally typed failures collapse through skips and products`() {
        requireFailure(TwoLiterals(), Mismatch.self)
        requireFailure(Skipped(), Mismatch.self)
    }

    @Test
    func `values nest to the left`() throws(any Swift.Error) {
        var input: Substring = "abc"
        let output = try ThreeLiterals().parse(&input)
        #expect(output.first.first == "a")
        #expect(output.first.second == "b")
        #expect(output.second == "c")
    }

    @Test
    func `noncopyable outputs pair into a noncopyable Pair`() throws(any Swift.Error) {
        var input: Substring = "ab"
        let output = try Tokens().parse(&input)
        #expect(output.first.value == "a")
        #expect(output.second.value == "b")
    }

    @Test
    func `a sixteen element body destructures through an annotated map`() throws(any Swift.Error) {
        var input: Substring = ",a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,"
        let output = try Sixteen().parse(&input)
        #expect(output == ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p"])
        #expect(input.isEmpty)
    }
}

private func requireFailure<P: Parser.`Protocol`, Failure: Swift.Error>(
    _: borrowing P,
    _: Failure.Type
) where P.Input: ~Copyable & ~Escapable, P.Output: ~Copyable & ~Escapable, P.Failure == Failure {}

private struct TwoLiterals: Parser.`Protocol` {
    typealias Failure = Mismatch

    var body: some Parser.`Protocol`<Substring, Pair<Character, Character>, Mismatch> {
        Literal("a")
        Literal("b")
    }
}

private struct MixedLiterals: Parser.`Protocol` {
    typealias Failure = Either<Mismatch, Other>

    var body: some Parser.`Protocol`<Substring, Pair<Character, Character>, Either<Mismatch, Other>> {
        Literal("a")
        OtherLiteral("b")
    }
}

private struct Skipped: Parser.`Protocol` {
    typealias Failure = Mismatch

    var body: some Parser.`Protocol`<Substring, Pair<Character, Character>, Mismatch> {
        Ignore("<")
        Literal("a")
        Ignore(",")
        Literal("b")
        Ignore(">")
    }
}

private struct ThreeLiterals: Parser.`Protocol` {
    typealias Failure = Mismatch

    var body: some Parser.`Protocol`<Substring, Pair<Pair<Character, Character>, Character>, Mismatch> {
        Literal("a")
        Literal("b")
        Literal("c")
    }
}

private struct Tokens: Parser.`Protocol` {
    typealias Failure = Mismatch

    var body: some Parser.`Protocol`<Substring, Pair<Token, Token>, Mismatch> {
        TokenLiteral("a")
        TokenLiteral("b")
    }
}

private struct Sixteen: Parser.`Protocol` {
    typealias Failure = Mismatch

    var body: some Parser.`Protocol`<Substring, [Character], Mismatch> {
        Parser.Sequence(Substring.self) {
            Ignore(",")
            Literal("a")
            Ignore(",")
            Literal("b")
            Ignore(",")
            Literal("c")
            Ignore(",")
            Literal("d")
            Ignore(",")
            Literal("e")
            Ignore(",")
            Literal("f")
            Ignore(",")
            Literal("g")
            Ignore(",")
            Literal("h")
            Ignore(",")
            Literal("i")
            Ignore(",")
            Literal("j")
            Ignore(",")
            Literal("k")
            Ignore(",")
            Literal("l")
            Ignore(",")
            Literal("m")
            Ignore(",")
            Literal("n")
            Ignore(",")
            Literal("o")
            Ignore(",")
            Literal("p")
            Ignore(",")
        }
        .map { p -> [Character] in
            [
                p.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first,
                p.first.first.first.first.first.first.first.first.first.first.first.first.first.first.second,
                p.first.first.first.first.first.first.first.first.first.first.first.first.first.second,
                p.first.first.first.first.first.first.first.first.first.first.first.first.second,
                p.first.first.first.first.first.first.first.first.first.first.first.second,
                p.first.first.first.first.first.first.first.first.first.first.second,
                p.first.first.first.first.first.first.first.first.first.second,
                p.first.first.first.first.first.first.first.first.second,
                p.first.first.first.first.first.first.first.second,
                p.first.first.first.first.first.first.second,
                p.first.first.first.first.first.second,
                p.first.first.first.first.second,
                p.first.first.first.second,
                p.first.first.second,
                p.first.second,
                p.second,
            ]
        }
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

private struct Ignore: Parser.`Protocol` {
    let expected: Character

    init(_ expected: Character) {
        self.expected = expected
    }

    borrowing func parse(_ input: inout Substring) throws(Mismatch) {
        guard input.first == expected else { throw .expected(expected) }
        input = input.dropFirst()
    }
}

private struct Literal: Parser.`Protocol` {
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

private struct OtherLiteral: Parser.`Protocol` {
    let expected: Character

    init(_ expected: Character) {
        self.expected = expected
    }

    borrowing func parse(_ input: inout Substring) throws(Other) -> Character {
        guard input.first == expected else { throw .expected(expected) }
        input = input.dropFirst()
        return expected
    }
}

private struct TokenLiteral: Parser.`Protocol` {
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
