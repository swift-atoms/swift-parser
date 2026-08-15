import Parser_Primitives_Test_Support
import Testing

// MARK: - Test Support Types

/// A leaf parser for a single ASCII decimal digit over `Substring`.
///
/// Value-producing, so a multi-value grammar can be composed.
private struct DecimalDigit: Parser.`Protocol` {
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

}

private struct Triple: Equatable {
    var a: Int
    var b: Int
    var c: Int
}

// MARK: - Test Suite Structure

@Suite
struct `Parser.Take.Two.Map` {
    @Suite struct `Conversion Boundary` {}
}

// MARK: - Conversion Boundary (friction F2)

extension `Parser.Take.Two.Map`.`Conversion Boundary` {
    /// The covered multi-value shape: a three-value grammar composed through
    /// **explicit** ``Parser/Take/Two`` nesting plus a
    /// ``Parser/Conversion/Memberwise`` reshape (the `.map(conversion)`
    /// bidirectional seam), rather than the implicit `@Parser.Builder`
    /// variadic flatten that routes through the one-way `Parser.Take.Two.Map`.
    ///
    /// The emission direction of this seam is covered by the coder-side rows.
    @Test
    func `three-value grammar parses through explicit Take.Two + conversion`() throws(any Swift
        .Error)
    {
        let grammar = Parser.Take.Two(
            Parser.Take.Two(DecimalDigit(), DecimalDigit()),
            DecimalDigit()
        )
        .map(
            .memberwise(
                { (values: ((Int, Int), Int)) in
                    Triple(a: values.0.0, b: values.0.1, c: values.1)
                },
                { (triple: Triple) in ((triple.a, triple.b), triple.c) }
            )
        )

        var input: Substring = "123"
        let parsed = try grammar.parse(&input)
        #expect(parsed == Triple(a: 1, b: 2, c: 3))
        #expect(input.isEmpty)
    }
}
