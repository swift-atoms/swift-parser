#if Lazy
import Lazy
import Parser
import Testing

@Suite
struct `Lazy Parser Tests` {

    @Test
    func `defers parser construction until parse time`() throws(any Swift.Error) {
        final class Box {
            var built = 0
        }
        let box = Box()

        let lazy = Lazy { () -> Literal in
            box.built += 1
            return Literal("a")
        }
        #expect(box.built == 0)

        var input: Substring = "abc"
        let output = try lazy.parse(&input)

        #expect(output == "a")
        #expect(input == "bc")
        #expect(box.built == 1)
    }

    @Test
    func `re-invokes the thunk on every parse`() throws(any Swift.Error) {
        final class Box {
            var built = 0
        }
        let box = Box()

        let lazy = Lazy { () -> Literal in
            box.built += 1
            return Literal("a")
        }

        var input: Substring = "aa"
        _ = try lazy.parse(&input)
        _ = try lazy.parse(&input)

        #expect(box.built == 2)
        #expect(input.isEmpty)
    }

    @Test
    func `propagates the wrapped parser's failure`() {
        let lazy = Lazy(Literal("a"))
        var input: Substring = "b"

        #expect(throws: LiteralError.expected("a")) {
            try lazy.parse(&input)
        }
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
