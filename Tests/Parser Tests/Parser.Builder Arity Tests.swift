import Either
import Parser
import Parser_Skip
import Parser_Take
import Testing

@Suite
struct `Parser.Builder arity` {

    @Test
    func `a twelve element body parses every element`() throws(any Swift.Error) {
        var input: Substring = "abcdefghijkZ"

        let output = try TwelveElements().parse(&input)

        #expect(output == "Z")
        #expect(input.isEmpty)
    }

    @Test
    func `a twelve element body stops at the first mismatch`() {
        var input: Substring = "abcdefghiXkZ"

        do {
            _ = try TwelveElements().parse(&input)
            Issue.record("Expected the tenth element to reject the input")
        } catch {
            #expect(input == "XkZ")
        }
    }

    @Test
    func `a twelve element body of void elements parses every element`() throws(any Swift.Error) {
        var input: Substring = "abcdefghijkl"

        try TwelveVoidElements().parse(&input)

        #expect(input.isEmpty)
    }

    @Test
    func `a twelve element body of void elements stops at the first mismatch`() {
        var input: Substring = "abcdefghijXl"

        do {
            try TwelveVoidElements().parse(&input)
            Issue.record("Expected the eleventh element to reject the input")
        } catch {
            #expect(input == "Xl")
        }
    }

    @Test
    func `a Take Sequence block accepts twelve elements`() throws(any Swift.Error) {
        var input: Substring = "abcdefghijkZ"

        let output = try Parser.Take.Sequence {
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
}

private struct TwelveElements: Parser.`Protocol` {
    typealias Input = Substring
    typealias Output = Character
    typealias Failure = Depth12

    var body: some Parser.`Protocol`<Substring, Character, Depth12> {
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
}

private struct TwelveVoidElements: Parser.`Protocol` {
    typealias Input = Substring
    typealias Output = Void
    typealias Failure = Depth12

    var body: some Parser.`Protocol`<Substring, Void, Depth12> {
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
        Ignore("l")
    }
}

private typealias Depth1 = Mismatch
private typealias Depth2 = Either<Depth1, Mismatch>
private typealias Depth3 = Either<Depth2, Mismatch>
private typealias Depth4 = Either<Depth3, Mismatch>
private typealias Depth5 = Either<Depth4, Mismatch>
private typealias Depth6 = Either<Depth5, Mismatch>
private typealias Depth7 = Either<Depth6, Mismatch>
private typealias Depth8 = Either<Depth7, Mismatch>
private typealias Depth9 = Either<Depth8, Mismatch>
private typealias Depth10 = Either<Depth9, Mismatch>
private typealias Depth11 = Either<Depth10, Mismatch>
private typealias Depth12 = Either<Depth11, Mismatch>

private enum Mismatch: Swift.Error, Equatable {
    case expected(Character)
}

private struct Ignore: Parser.`Protocol` {
    typealias Input = Substring
    typealias Output = Void
    typealias Failure = Mismatch
    typealias Body = Never

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
    typealias Input = Substring
    typealias Output = Character
    typealias Failure = Mismatch
    typealias Body = Never

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
