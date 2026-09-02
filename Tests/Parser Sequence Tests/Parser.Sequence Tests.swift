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
