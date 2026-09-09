#if Either
import Either
import Parser
import Testing
import Parser_Test_Support

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
private func branch(_ useLeft: Bool) -> Either<Literal, Literal>.Parser {
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

private struct Selected: Parsing {
    typealias Failure = Either<LiteralError, LiteralError>
    let useLeft: Bool
    var body: some Parsing<Substring, Character, Either<LiteralError, LiteralError>> {
        if useLeft { Literal("a") } else { Literal("b") }
    }
}

extension `Either Parser` {
    @Test func `a body preserves conditional syntax`() throws {
        var input: Substring = "abc"
        #expect(try Selected(useLeft: true).parse(&input) == "a")
        #expect(try Selected(useLeft: false).parse(&input) == "b")
        #expect(input == "c")
    }
    @Test func `explicit and builder adapters wrap an existing either`() throws {
        let selected: Either<Literal, Literal> = .left(Literal("a"))
        var input: Substring = "aab"
        #expect(try selected.parser().parse(&input) == "a")
        #expect(try Parser { selected }.parse(&input) == "a")
        #expect(input == "b")
    }
}

private final class Lifetime {
    var destroyed = 0
}

private struct Owned: Parsing, ~Copyable {
    typealias Input = Substring
    typealias Output = Int
    typealias Failure = Never
    let lifetime: Lifetime
    let result: Int
    deinit { lifetime.destroyed += 1 }
    func parse(_ input: inout Substring) -> Int { result }
}

private struct Conditional: Parsing {
    typealias Failure = Either<Never, Never>
    let lifetime: Lifetime
    let useLeft: Bool
    var body: some Parsing<Substring, Int, Either<Never, Never>> & ~Copyable {
        if useLeft {
            Owned(lifetime: lifetime, result: 1)
        } else {
            Owned(lifetime: lifetime, result: 2)
        }
    }
}

extension `Either Parser` {
    @Test(arguments: [true, false])
    func `noncopyable branches are borrowed repeatedly and destroyed once`(_ useLeft: Bool) throws {
        let lifetime = Lifetime()
        var input: Substring = "abc"
        do {
            let selected: Either<Owned, Owned> = useLeft
                ? .left(Owned(lifetime: lifetime, result: 1))
                : .right(Owned(lifetime: lifetime, result: 2))
            let parser = selected.parser()
            #expect(try parser.parse(&input) == (useLeft ? 1 : 2))
            #expect(try parser.parse(&input) == (useLeft ? 1 : 2))
            #expect(lifetime.destroyed == 0)
        }
        #expect(lifetime.destroyed == 1)
        #expect(try Conditional(lifetime: lifetime, useLeft: useLeft).parse(&input) == (useLeft ? 1 : 2))
        #expect(lifetime.destroyed == 2)
    }
}

extension `Either Parser` {
    @Test func `conditional scoped results survive module emission`() throws {
        let result = try Compiler.emitFixture(named: "Scoped Result.swift", in: "Either")
        #expect(result.status == 0, "\(result.diagnostic)")
    }
    @Test func `conditional scoped results cannot escape their input`() throws {
        let diagnostic = try Compiler.emissionFailure(named: "Escaping Result.swift", in: "Either")
        #expect(diagnostic.contains("lifetime") || diagnostic.contains("escapes"))
    }
}
#endif
