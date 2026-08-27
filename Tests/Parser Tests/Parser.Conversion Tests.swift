import Parser
import Parser_Standard_Library_Integration
import Testing

private struct Digit: Parser.`Protocol` {
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

private struct Head: Parser.`Protocol` {
    typealias Input = Substring
    typealias Output = Substring
    typealias Failure = Parser.Match.Error
    typealias Body = Never

    func parse(_ input: inout Substring) throws(Parser.Match.Error) -> Substring {
        guard input.first != nil else {
            throw .predicateFailed(description: "expected a character")
        }
        let head = input.prefix(1)
        input = input.dropFirst()
        return head
    }

}

private struct Point: Equatable {
    var x: Int
    var y: Int
}

private struct Tag: RawRepresentable, Equatable {
    var rawValue: Int
}

private enum Node: Equatable {
    case leaf(Int)
    case empty
}

@Suite
struct `Parser.Conversion` {
    @Suite struct `Combinator` {}
    @Suite struct `Parser Map` {}
    @Suite struct `Builder Propagation` {}
}

extension `Parser.Conversion`.`Combinator` {
    @Test
    func `identity round-trips both directions`() {
        let conversion = Parser.Conversion.Identity<Int>()
        #expect(conversion.apply(7) == 7)
        #expect(conversion.unapply(7) == 7)
    }

    @Test
    func `raw value applies and un-applies`() throws(any Swift.Error) {
        let conversion = Parser.Conversion.RawValue<Tag>()
        #expect(try conversion.apply(3) == Tag(rawValue: 3))
        #expect(conversion.unapply(Tag(rawValue: 3)) == 3)
    }

    @Test
    func `fixed injects and verifies the constant`() throws(any Swift.Error) {
        let conversion = Parser.Conversion.Fixed(42)
        #expect(conversion.apply(()) == 42)
        try conversion.unapply(42)
        #expect(throws: Parser.Conversion.Error.mismatch) {
            try conversion.unapply(41)
        }
    }

    @Test
    func `memberwise embeds a tuple and projects a struct`() {
        let conversion = Parser.Conversion.Memberwise<(Int, Int), Point>(
            embed: { Point(x: $0.0, y: $0.1) },
            project: { ($0.x, $0.y) }
        )
        #expect(conversion.apply((1, 2)) == Point(x: 1, y: 2))
        let projected = conversion.unapply(Point(x: 1, y: 2))
        #expect(projected.0 == 1)
        #expect(projected.1 == 2)
    }

    @Test
    func `witness round-trips a closure pair`() throws(any Swift.Error) {
        let conversion = Parser.Conversion.Witness<Int, Int, Never>(
            apply: { $0 + 100 },
            unapply: { $0 - 100 }
        )
        #expect(conversion.apply(5) == 105)
        #expect(conversion.unapply(105) == 5)
    }

    @Test
    func `case embeds a payload and extracts it`() throws(any Swift.Error) {
        let conversion = Parser.Conversion.Case<Node, Int>(
            embed: Node.leaf,
            extract: { if case .leaf(let value) = $0 { value } else { nil } }
        )

        #expect(conversion.apply(7) == .leaf(7))

        #expect(try conversion.unapply(.leaf(7)) == 7)

        #expect(throws: Parser.Conversion.Error.absentCase) {
            try conversion.unapply(.empty)
        }
    }

    @Test
    func `string copies a substring and wraps it back`() {
        let conversion = Parser.Conversion.String()
        #expect(conversion.apply("route") == "route")
        #expect(conversion.unapply("route") == Substring("route"))
    }

    @Test
    func `map composes two conversions`() throws(any Swift.Error) {

        let conversion = Parser.Conversion.Identity<Int>()
            .map(Parser.Conversion.RawValue<Tag>())
        #expect(try conversion.apply(9) == Tag(rawValue: 9))
        #expect(try conversion.unapply(Tag(rawValue: 9)) == 9)
    }
}

extension `Parser.Conversion`.`Parser Map` {
    @Test
    func `converted parser applies over a direct Take.Two`() throws(any Swift.Error) {
        let grammar = Parser.Take.Two(Digit(), Digit())
            .map(
                .memberwise(
                    { (values: (Int, Int)) in Point(x: values.0, y: values.1) },
                    { (point: Point) in (point.x, point.y) }
                )
            )

        var input: Substring = "34"
        let parsed = try grammar.parse(&input)
        #expect(parsed == Point(x: 3, y: 4))
        #expect(input.isEmpty)
    }

    @Test
    func `string lifts a Substring parser to a String parser`() throws(any Swift.Error) {

        let grammar = Head().map(.string)

        var input: Substring = "x"
        #expect(try grammar.parse(&input) == "x")
        #expect(input.isEmpty)
    }

    @Test
    func `converted parser lifts a raw value`() throws(any Swift.Error) {
        let grammar = Digit().map(.representing(Tag.self))

        var input: Substring = "5"
        #expect(try grammar.parse(&input) == Tag(rawValue: 5))
    }

    @Test
    func `converted parser embeds into an enum case`() throws(any Swift.Error) {

        let grammar = Digit().map(
            .case(
                embed: Node.leaf,
                extract: { (node: Node) in if case .leaf(let value) = node { value } else { nil } }
            )
        )

        var input: Substring = "8"
        #expect(try grammar.parse(&input) == .leaf(8))
    }
}

extension `Parser.Conversion`.`Builder Propagation` {

    @Test
    func `builder-composed grammar parses through a conversion`() throws(any Swift.Error) {
        let grammar = Parser.Take.Sequence {
            "#"
            Digit()
        }
        .map(.representing(Tag.self))

        var input: Substring = "#7"
        let parsed = try grammar.parse(&input)
        #expect(parsed == Tag(rawValue: 7))
        #expect(input.isEmpty)
    }
}
