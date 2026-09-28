#if IteratorLeaves && Pair && Either
import Either
import Iterator
import Parser
import Parser
import Testing

@Suite
struct `Parser::First Tests` {

    @Test
    func `Element returns the first element and advances`() throws(any Swift.Error) {
        var input = Characters("abc")
        #expect(try Parser::First.Element<Characters>().parse(&input) == "a")
        #expect(input.remainder == "bc")
    }

    @Test
    func `Element reports the end of input`() {
        var input = Characters("")
        #expect(throws: Parser::EndOfInput.Error.unexpected(expected: "any element")) {
            try Parser::First.Element<Characters>().parse(&input)
        }
    }

    @Test
    func `Where returns a matching element`() throws(any Swift.Error) {
        var input = Characters("a1")
        #expect(try Parser::First.Where<Characters>(expected: "letter", \.isLetter).parse(&input) == "a")
        #expect(input.remainder == "1")
    }

    @Test
    func `Where rejects a non-matching element on the right`() {
        var input = Characters("1a")
        #expect(throws: Parser::First.Where<Characters>.Failure.right(.predicateFailed(expected: "letter"))) {
            try Parser::First.Where<Characters>(expected: "letter", \.isLetter).parse(&input)
        }
    }

    @Test
    func `Where reports the end of input on the left`() {
        var input = Characters("")
        #expect(throws: Parser::First.Where<Characters>.Failure.left(.unexpected(expected: "letter"))) {
            try Parser::First.Where<Characters>(expected: "letter", \.isLetter).parse(&input)
        }
    }
}

private struct Characters: Iterator.`Protocol` {
    var remainder: Substring

    init(_ text: String) {
        remainder = text[...]
    }

    mutating func next() -> Character? {
        remainder.popFirst()
    }
}


extension `Parser::First Tests` {
    @Test func predicateFailureConsumesExactlyOneElementAndEvaluatesOnce() {
        var input = Characters("1a")
        var calls = 0
        let parser = Parser::First.Where<Characters> { value in
            calls += 1
            return value.isLetter
        }
        #expect(throws: Parser::First.Where<Characters>.Failure.right(
            .predicateFailed(expected: "matching element")
        )) { try parser.parse(&input) }
        #expect(calls == 1)
        #expect(input.remainder == "a")
    }

    @Test func noncopyableIteratorWorksAcrossLeafAndLiteralParsers() throws {
        var input = OwnedNumbers()
        #expect(try Parser::First.Element<OwnedNumbers>().parse(&input) == 0)
        try Parser::ConsumingLiteral<OwnedNumbers>([1, 2]).parse(&input)
        #expect(input.nextValue == 3)
        #expect(try Parser::First.Where<OwnedNumbers> { $0 == 3 }.parse(&input) == 3)
        #expect(input.nextValue == 4)
    }
}

private struct OwnedNumbers: ~Copyable, Iterator.`Protocol` {
    var nextValue = 0
    mutating func next() -> Int? {
        guard nextValue < 4 else { return nil }
        defer { nextValue += 1 }
        return nextValue
    }
}
#endif
