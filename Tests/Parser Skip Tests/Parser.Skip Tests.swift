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

@Suite
struct `Parser.Skip Nonescapable Input` {

    @Test
    func `Skip.First and Skip.Second pass a value through a nonescapable cursor`() throws(any Swift.Error) {
        let bytes: [UInt8] = [0x3C, 7, 0x3E]
        var cursor = Cursor(bytes.span)
        let value = try Framed().parse(&cursor)
        let end = cursor.index
        #expect(value == 7)
        #expect(end == 3)
    }

    @Test
    func `a skipped marker failure surfaces through a nonescapable cursor`() {
        let bytes: [UInt8] = [0x3C, 7, 0x21]
        var cursor = Cursor(bytes.span)
        var failure: ByteMismatch?
        do {
            _ = try Framed().parse(&cursor)
        } catch {
            failure = error
        }
        #expect(failure == .expected(0x3E))
    }
}

private struct Framed: Parser.`Protocol` {
    typealias Failure = ByteMismatch

    var body: some Parser.`Protocol`<Cursor, UInt8, ByteMismatch> {
        ByteMarker(0x3C)
        ByteValue()
        ByteMarker(0x3E)
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
    case expected(UInt8)
    case endOfInput
}

private struct ByteMarker: Parser.`Protocol` {
    let expected: UInt8

    init(_ expected: UInt8) {
        self.expected = expected
    }

    borrowing func parse(_ input: inout Cursor) throws(ByteMismatch) {
        guard input.index < input.span.count else { throw .endOfInput }
        guard input.span[input.index] == expected else { throw .expected(expected) }
        input.index += 1
    }
}

private struct ByteValue: Parser.`Protocol` {
    borrowing func parse(_ input: inout Cursor) throws(ByteMismatch) -> UInt8 {
        guard input.index < input.span.count else { throw .endOfInput }
        let byte = input.span[input.index]
        input.index += 1
        return byte
    }
}
