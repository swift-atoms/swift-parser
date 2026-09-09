import Either
import Parser
import Testing

@Suite
struct `Parser skip and append preserve tuple shape and stage failures` {

    @Test
    func `a void then a value is the value`() throws(any Swift.Error) {
        var input: Substring = "<x"
        let output = try LeadingSkip().parse(&input)
        #expect(output == "x")
        #expect(input.isEmpty)
        requireOutput(LeadingSkip(), Character.self)
    }

    @Test
    func `a value then a void is the value`() throws(any Swift.Error) {
        var input: Substring = "x>"
        let output = try TrailingSkip().parse(&input)
        #expect(output == "x")
        #expect(input.isEmpty)
        requireOutput(TrailingSkip(), Character.self)
    }

    @Test
    func `two voids are Void`() throws(any Swift.Error) {
        var input: Substring = "<>"
        try VoidPair().parse(&input)
        #expect(input.isEmpty)
        requireOutput(VoidPair(), Void.self)
    }

    @Test
    func `values separated by voids are one flat tuple`() throws(any Swift.Error) {
        var input: Substring = "a,b,c"
        let output = try Three().parse(&input)
        #expect(output.0 == "a")
        #expect(output.1 == "b")
        #expect(output.2 == "c")
        #expect(input.isEmpty)
        requireOutput(Three(), (Character, Character, Character).self)
    }

    @Test
    func `leading and trailing voids around two values are a pair tuple`() throws(any Swift.Error) {
        var input: Substring = "<ab>"
        let output = try Framed().parse(&input)
        #expect(output.0 == "a")
        #expect(output.1 == "b")
        #expect(input.isEmpty)
        requireOutput(Framed(), (Character, Character).self)
    }

    @Test
    func `differently typed failures nest in Either`() {
        requireFailure(MixedFailures(), Either<Mismatch, Other>.self)
    }

    @Test
    func `equally typed failures collapse through every step`() {
        requireFailure(LeadingSkip(), Mismatch.self)
        requireFailure(TrailingSkip(), Mismatch.self)
        requireFailure(VoidPair(), Mismatch.self)
        requireFailure(Three(), Mismatch.self)
        requireFailure(Framed(), Mismatch.self)
        requireFailure(Sixteen(), Mismatch.self)
    }

    @Test
    func `a leading skip failure surfaces the skipped element's error`() {
        var input: Substring = "!x"
        #expect(throws: Mismatch.expected("<")) {
            try LeadingSkip().parse(&input)
        }
    }

    @Test
    func `a trailing skip failure surfaces after the value parsed`() {
        var input: Substring = "x!"
        #expect(throws: Mismatch.expected(">")) {
            try TrailingSkip().parse(&input)
        }
        #expect(input == "!")
    }

    @Test
    func `a sixteen element body is a flat sixteen tuple`() throws(any Swift.Error) {
        var input: Substring = ",a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,"
        let output = try Sixteen().parse(&input)
        #expect(output == ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p"])
        #expect(input.isEmpty)
    }
}

private func requireOutput<P: Parsing, Output>(
    _: borrowing P,
    _: Output.Type
) where P.Input: ~Copyable & ~Escapable, P.Output == Output {}

private func requireFailure<P: Parsing, Failure: Swift.Error>(
    _: borrowing P,
    _: Failure.Type
) where P.Input: ~Copyable & ~Escapable, P.Output: ~Copyable & ~Escapable, P.Failure == Failure {}

private struct LeadingSkip: Parsing {
    typealias Failure = Mismatch

    var body: some Parsing<Substring, Character, Mismatch> {
        Ignore("<")
        Literal("x")
    }
}

private struct TrailingSkip: Parsing {
    typealias Failure = Mismatch

    var body: some Parsing<Substring, Character, Mismatch> {
        Literal("x")
        Ignore(">")
    }
}

private struct VoidPair: Parsing {
    typealias Failure = Mismatch

    var body: some Parsing<Substring, Void, Mismatch> {
        Ignore("<")
        Ignore(">")
    }
}

private struct Three: Parsing {
    typealias Failure = Mismatch

    var body: some Parsing<Substring, (Character, Character, Character), Mismatch> {
        Literal("a")
        Ignore(",")
        Literal("b")
        Ignore(",")
        Literal("c")
    }
}

private struct Framed: Parsing {
    typealias Failure = Mismatch

    var body: some Parsing<Substring, (Character, Character), Mismatch> {
        Ignore("<")
        Literal("a")
        Literal("b")
        Ignore(">")
    }
}

private struct MixedFailures: Parsing {
    typealias Failure = Either<Mismatch, Other>

    var body: some Parsing<Substring, Character, Either<Mismatch, Other>> {
        Ignore("<")
        OtherLiteral("x")
    }
}

private struct Sixteen: Parsing {
    typealias Failure = Mismatch

    var body: some Parsing<Substring, [Character], Mismatch> {
        Builder<Substring>.buildBlock(
            Builder<Substring>.buildPartialBlock(
                accumulated: SixteenBody().body,
                next: Ignore(",")
            )
        )
        .map { p -> [Character] in
            [p.0, p.1, p.2, p.3, p.4, p.5, p.6, p.7, p.8, p.9, p.10, p.11, p.12, p.13, p.14, p.15]
        }
    }
}

private struct SixteenBody: Parsing {
    typealias Failure = Mismatch

    var body: some Parsing<
        Substring,
        (Character, Character, Character, Character, Character, Character, Character, Character,
         Character, Character, Character, Character, Character, Character, Character, Character),
        Mismatch
    > {
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
    }
}

private enum Mismatch: Swift.Error, Equatable {
    case expected(Character)
}

private enum Other: Swift.Error, Equatable {
    case expected(Character)
}

private struct Ignore: Parsing {
    let expected: Character

    init(_ expected: Character) {
        self.expected = expected
    }

    borrowing func parse(_ input: inout Substring) throws(Mismatch) {
        guard input.first == expected else { throw .expected(expected) }
        input = input.dropFirst()
    }
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

private struct OtherLiteral: Parsing {
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
struct `Parser skip and append preserve values and failures over nonescapable cursors` {

    @Test
    func `Append and Skip pass a value through a nonescapable cursor`() throws(any Swift.Error) {
        let bytes: [UInt8] = [0x3C, 7, 0x3E]
        var cursor = Cursor(bytes.span)
        let value = try FramedByte().parse(&cursor)
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
            _ = try FramedByte().parse(&cursor)
        } catch {
            failure = error
        }
        #expect(failure == .expected(0x3E))
    }
}

private struct FramedByte: Parsing {
    typealias Failure = ByteMismatch

    var body: some Parsing<Cursor, UInt8, ByteMismatch> {
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

private struct ByteMarker: Parsing {
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

private struct ByteValue: Parsing {
    borrowing func parse(_ input: inout Cursor) throws(ByteMismatch) -> UInt8 {
        guard input.index < input.span.count else { throw .endOfInput }
        let byte = input.span[input.index]
        input.index += 1
        return byte
    }
}
