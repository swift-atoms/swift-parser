#if Either
import Either
import Parser
import Testing

@Suite
struct `Either Parser` {

    @Test
    func `parses the selected left parser`() throws(any Swift.Error) {
        var input: Substring = "abc"

        let output = try branch(true).parse(&input)

        #expect(output == "a")
        #expect(input == "bc")
    }

    @Test
    func `parses the selected right parser`() throws(any Swift.Error) {
        var input: Substring = "bac"

        let output = try branch(false).parse(&input)

        #expect(output == "b")
        #expect(input == "ac")
    }

    @Test
    func `a failing left branch reports Either left`() {
        var input: Substring = "xbc"
        #expect(throws: Either<LiteralError, LiteralError>.left(.expected("a"))) {
            try branch(true).parse(&input)
        }
    }

    @Test
    func `a failing right branch reports Either right`() {
        var input: Substring = "xac"
        #expect(throws: Either<LiteralError, LiteralError>.right(.expected("b"))) {
            try branch(false).parse(&input)
        }
    }
}

@Builder<Substring>
private func branch(_ useLeft: Bool) -> Either<Literal, Literal> {
    if useLeft {
        Literal("a")
    } else {
        Literal("b")
    }
}

private enum LiteralError: Error, Equatable {
    case expected(Character)
}

private struct Literal: Parsing {
    typealias Input = Substring
    typealias Output = Character
    typealias Failure = LiteralError

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

#endif
