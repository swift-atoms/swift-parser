import Parser
import Parser_Skip
import Testing

@Suite
struct `Parser.Skip arity` {

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

}

private struct TwelveElements: Parser.`Protocol` {
    typealias Input = Substring
    typealias Output = Character
    typealias Failure = Mismatch

    var body: some Parser.`Protocol`<Substring, Character, Mismatch> {
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
    typealias Failure = Mismatch

    var body: some Parser.`Protocol`<Substring, Void, Mismatch> {
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


private enum Mismatch: Swift.Error, Equatable {
    case expected(Character)
}

private struct Ignore: Parser.`Protocol` {
    typealias Input = Substring
    typealias Output = Void
    typealias Failure = Mismatch

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
