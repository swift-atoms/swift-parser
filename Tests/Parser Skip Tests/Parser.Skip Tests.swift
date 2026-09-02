import Either
import Parser
import Parser_Skip
import Testing

@Suite
struct `Parser.Skip` {

    @Test
    func `skips a leading void element`() throws(any Swift.Error) {
        var input: Substring = "<x"
        let output = try LeadingSkip().parse(&input)
        #expect(output == "x")
        #expect(input.isEmpty)
    }

    @Test
    func `skips a trailing void element`() throws(any Swift.Error) {
        var input: Substring = "x>"
        let output = try TrailingSkip().parse(&input)
        #expect(output == "x")
        #expect(input.isEmpty)
    }

    @Test
    func `two void elements produce a void body`() throws(any Swift.Error) {
        var input: Substring = "<>"
        try VoidPair().parse(&input)
        #expect(input.isEmpty)
    }

    @Test
    func `differently typed failures nest in Either`() {
        requireFailure(MixedFailures(), Either<Mismatch, Other>.self)
    }

    @Test
    func `equally typed failures collapse to that type`() {
        requireFailure(LeadingSkip(), Mismatch.self)
        requireFailure(TrailingSkip(), Mismatch.self)
        requireFailure(VoidPair(), Mismatch.self)
    }

    @Test
    func `a leading skip failure surfaces the skipped element's error`() {
        var input: Substring = "!x"
        #expect(throws: Mismatch.expected("<")) {
            try LeadingSkip().parse(&input)
        }
    }
}

private func requireFailure<P: Parser.`Protocol`, Failure: Swift.Error>(
    _: borrowing P,
    _: Failure.Type
) where P.Input: ~Copyable & ~Escapable, P.Output: ~Copyable & ~Escapable, P.Failure == Failure {}

private struct LeadingSkip: Parser.`Protocol` {
    typealias Failure = Mismatch

    var body: some Parser.`Protocol`<Substring, Character, Mismatch> {
        Ignore("<")
        Literal("x")
    }
}

private struct TrailingSkip: Parser.`Protocol` {
    typealias Failure = Mismatch

    var body: some Parser.`Protocol`<Substring, Character, Mismatch> {
        Literal("x")
        Ignore(">")
    }
}

private struct VoidPair: Parser.`Protocol` {
    typealias Failure = Mismatch

    var body: some Parser.`Protocol`<Substring, Void, Mismatch> {
        Ignore("<")
        Ignore(">")
    }
}

private struct MixedFailures: Parser.`Protocol` {
    typealias Failure = Either<Mismatch, Other>

    var body: some Parser.`Protocol`<Substring, Character, Either<Mismatch, Other>> {
        Ignore("<")
        OtherLiteral("x")
    }
}

private enum Mismatch: Swift.Error, Equatable {
    case expected(Character)
}

private enum Other: Swift.Error, Equatable {
    case expected(Character)
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
