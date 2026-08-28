import Parser
import Testing

@Suite
struct `Parser.Parse` {

    @Test
    func `direct parse method remains the execution primitive`() throws(any Swift.Error) {
        var input: Substring = "abc"

        let output = try Literal("a").parse(&input)

        #expect(output == "a")
        #expect(input == "bc")
    }

    @Test
    func `parse facade provides a focused extension point`() {
        #expect(Literal("a").parse.expected == "a")
    }

    @Test
    func `Parse can directly own a noncopyable parser`() {
        let parse = Parser.Parse(parser: NoncopyableLiteral("a"))

        #expect(parse.expected == "a")
    }
}

extension Parser.Parse where P == Literal {

    fileprivate var expected: Character {
        parser.expected
    }
}

extension Parser.Parse where P == NoncopyableLiteral {

    fileprivate var expected: Character {
        parser.expected
    }
}

private enum LiteralError: Error {
    case expected(Character)
}

private struct Literal: Parser.`Protocol` {
    typealias Input = Substring
    typealias Output = Character
    typealias Failure = LiteralError
    typealias Body = Never

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

private struct NoncopyableLiteral: ~Copyable, Parser.`Protocol` {
    typealias Input = Substring
    typealias Output = Character
    typealias Failure = LiteralError
    typealias Body = Never

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
