import Parser_Primitives_Test_Support
import Testing

// MARK: - Test Support Types

/// A bidirectional leaf parser-printer for a single ASCII decimal digit over
/// `Substring`. Value-producing, so a multi-value grammar can be composed.
private struct DecimalDigit: Parser.Bidirectional {
    typealias Input = Substring
    typealias Output = Int
    typealias Failure = Parser.Match.Error
    typealias Body = Never

    func parse(_ input: inout Substring) throws(Parser.Match.Error) -> Int {
        guard let character = input.first,
              ("0"..."9").contains(character),
              let digit = character.wholeNumberValue
        else {
            throw .predicateFailed(description: "expected decimal digit")
        }
        input = input.dropFirst()
        return digit
    }

    func print(_ output: Int, into input: inout Substring) throws(Parser.Match.Error) {
        guard (0...9).contains(output) else {
            throw .predicateFailed(description: "digit out of range 0...9")
        }
        input.insert(contentsOf: String(output), at: input.startIndex)
    }
}

private struct Triple: Equatable {
    var a: Int
    var b: Int
    var c: Int
}

// MARK: - Test Suite Structure

@Suite
struct `Parser.Take.Two.Map` {
    @Suite struct `Printing Boundary` {}
}

// MARK: - Printing Boundary (friction F2)

extension `Parser.Take.Two.Map`.`Printing Boundary` {
    /// The covered multi-value shape: a three-value grammar retains
    /// printability when the values are composed through **explicit**
    /// ``Parser/Take/Two`` nesting plus a ``Parser/Conversion/Memberwise``
    /// reshape (the `.map(conversion)` bidirectional seam), rather than the
    /// implicit `@Parser.Builder` variadic flatten that routes through the
    /// parse-only `Parser.Take.Two.Map`. This is the consumer-side resolution
    /// documented on `Parser.Take.Two.Map`.
    @Test
    func `three-value grammar round-trips through explicit Take.Two + conversion`() throws(any Swift.Error) {
        let grammar = Parser.Take.Two(Parser.Take.Two(DecimalDigit(), DecimalDigit()), DecimalDigit())
            .map(.memberwise(
                { (values: ((Int, Int), Int)) in
                    Triple(a: values.0.0, b: values.0.1, c: values.1)
                },
                { (triple: Triple) in ((triple.a, triple.b), triple.c) }
            ))

        var input: Substring = "123"
        let parsed = try grammar.parse(&input)
        #expect(parsed == Triple(a: 1, b: 2, c: 3))
        #expect(input.isEmpty)

        var output: Substring = ""
        try grammar.print(Triple(a: 1, b: 2, c: 3), into: &output)
        #expect(output == "123")
    }
}
