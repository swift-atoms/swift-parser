import Either
import Parser
import Parser_Sequence
import Parser_Skip
import Testing

@Suite
struct `Parser.Sequence` {

    @Test
    func `a block accepts twelve elements`() throws(any Swift.Error) {
        var input: Substring = "abcdefghijkZ"

        let output = try Parser.Sequence(Substring.self) {
            Ignore("a")
            Ignore("b")
            Ignore("c")
            Ignore("d")
            Ignore("e")
            Ignore("f")
            Ignore("g")
            Ignore("h")
            Ignore("i")
            Ignore("j")
            Ignore("k")
            Literal("Z")
        }
        .parse(&input)

        #expect(output == "Z")
        #expect(input.isEmpty)
    }

    @Test
    func `a block infers its input from the elements`() throws(any Swift.Error) {
        var input: Substring = "aZ"
        let sequence = Parser.Sequence {
            Ignore("a")
            Literal("Z")
        }
        #expect(try sequence.parse(&input) == "Z")
    }

    @Test
    func `a block's failure is its body's failure`() {
        let sequence = Parser.Sequence(Substring.self) {
            Ignore("a")
            Literal("Z")
        }
        requireFailure(sequence, Mismatch.self)
    }
}

private func requireFailure<P: Parser.`Protocol`, Failure: Swift.Error>(
    _: borrowing P,
    _: Failure.Type
) where P.Input: ~Copyable & ~Escapable, P.Output: ~Copyable & ~Escapable, P.Failure == Failure {}

private enum Mismatch: Swift.Error, Equatable {
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

@Suite
struct `Parser.Sequence Nonescapable Input` {

    @Test
    func `a block nests inside a body over a nonescapable cursor`() throws(any Swift.Error) {
        let bytes: [UInt8] = [0x28, 7, 0x29, 0x2E]
        var cursor = Cursor(bytes.span)
        let value = try Sentence().parse(&cursor)
        let end = cursor.index
        #expect(value == 7)
        #expect(end == 4)
    }
}

private struct Sentence: Parser.`Protocol` {
    typealias Failure = ByteMismatch

    var body: some Parser.`Protocol`<Cursor, UInt8, ByteMismatch> {
        Parser.Sequence(Cursor.self) {
            ByteMarker(0x28)
            ByteValue()
            ByteMarker(0x29)
        }
        ByteMarker(0x2E)
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
