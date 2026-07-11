import Parser_Primitives_Test_Support
import Testing

// MARK: - Test Support Types

/// A bidirectional leaf parser-printer for a single ASCII decimal digit over
/// `Substring`. Used to build value-producing grammars for the round-trip and
/// builder-propagation probes.
private struct Digit: Parser.Bidirectional {
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

/// A bidirectional leaf that consumes/produces the first character of a
/// `Substring` as a `Substring`. Used to exercise the `.string` conversion
/// (`Substring -> String`) through the printer-preserving `.map(conversion)`
/// seam.
private struct Head: Parser.Bidirectional {
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

    func print(_ output: Substring, into input: inout Substring) throws(Parser.Match.Error) {
        input.insert(contentsOf: output, at: input.startIndex)
    }
}

private struct Point: Equatable {
    var x: Int
    var y: Int
}

private struct Tag: RawRepresentable, Equatable {
    var rawValue: Int
    init(rawValue: Int) { self.rawValue = rawValue }
}

/// A payload-carrying enum used to probe ``Parser/Conversion/Case``: `leaf`
/// carries an `Int` payload, `empty` is the wrong case that makes `unapply`
/// (extract) fail.
private enum Node: Equatable {
    case leaf(Int)
    case empty
}

// MARK: - Test Suite Structure

@Suite
struct `Parser.Conversion` {
    @Suite struct `Combinator` {}
    @Suite struct `Parser Map` {}
    @Suite struct `Builder Propagation` {}
}

// MARK: - Conversion Combinator Round-Trips

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
        try conversion.unapply(42)  // matches — no throw
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
            extract: { if case let .leaf(value) = $0 { value } else { nil } }
        )
        // apply embeds the payload into its case.
        #expect(conversion.apply(7) == .leaf(7))
        // unapply extracts the payload from the matching case.
        #expect(try conversion.unapply(.leaf(7)) == 7)
        // unapply throws on the wrong case.
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
        // Int --Identity--> Int --RawValue--> Tag
        let conversion = Parser.Conversion.Identity<Int>()
            .map(Parser.Conversion.RawValue<Tag>())
        #expect(try conversion.apply(9) == Tag(rawValue: 9))
        #expect(try conversion.unapply(Tag(rawValue: 9)) == 9)
    }
}

// MARK: - .map(conversion) on a Parser-Printer

extension `Parser.Conversion`.`Parser Map` {
    @Test
    func `converted parser is bidirectional over a direct Take.Two`() throws(any Swift.Error) {
        let grammar = Parser.Take.Two(Digit(), Digit())
            .map(.memberwise(
                { (values: (Int, Int)) in Point(x: values.0, y: values.1) },
                { (point: Point) in (point.x, point.y) }
            ))

        var input: Substring = "34"
        let parsed = try grammar.parse(&input)
        #expect(parsed == Point(x: 3, y: 4))
        #expect(input.isEmpty)

        var output: Substring = ""
        try grammar.print(Point(x: 3, y: 4), into: &output)
        #expect(output == "34")
    }

    @Test
    func `string lifts a Substring parser to a String parser`() throws(any Swift.Error) {
        // `.string` resolves to Parser.Conversion.String and preserves
        // printability: parse copies out a String, print wraps it back.
        let grammar = Head().map(.string)

        var input: Substring = "x"
        #expect(try grammar.parse(&input) == "x")
        #expect(input.isEmpty)

        var output: Substring = ""
        try grammar.print("x", into: &output)
        #expect(output == "x")
    }

    @Test
    func `converted parser lifts a raw value`() throws(any Swift.Error) {
        let grammar = Digit().map(.representing(Tag.self))

        var input: Substring = "5"
        #expect(try grammar.parse(&input) == Tag(rawValue: 5))

        var output: Substring = ""
        try grammar.print(Tag(rawValue: 5), into: &output)
        #expect(output == "5")
    }

    @Test
    func `converted parser embeds into an enum case`() throws(any Swift.Error) {
        // Digit parses an Int payload; `.case` embeds it into `Node.leaf`,
        // exercising the printer-preserving `.map(conversion)` seam through
        // Parser.Conversion.Case.
        let grammar = Digit().map(
            .case(
                embed: Node.leaf,
                extract: { (node: Node) in if case let .leaf(value) = node { value } else { nil } }
            )
        )

        var input: Substring = "8"
        #expect(try grammar.parse(&input) == .leaf(8))

        var output: Substring = ""
        try grammar.print(.leaf(8), into: &output)
        #expect(output == "8")
    }
}

// MARK: - Builder-Propagation Acceptance Probe

extension `Parser.Conversion`.`Builder Propagation` {
    /// The acceptance probe: a grammar composed through the `Take.Builder`
    /// result builder (`Parser.Take.Sequence { … }`) provably prints through a
    /// `Conversion`. This exercises the builder-propagation fix
    /// (`Parser.Take.Sequence: Parser.Printer`) together with `.map(conversion)`.
    @Test
    func `builder-composed grammar round-trips through a conversion`() throws(any Swift.Error) {
        let grammar = Parser.Take.Sequence {
            "#"
            Digit()
        }
        .map(.representing(Tag.self))

        var input: Substring = "#7"
        let parsed = try grammar.parse(&input)
        #expect(parsed == Tag(rawValue: 7))
        #expect(input.isEmpty)

        var output: Substring = ""
        try grammar.print(Tag(rawValue: 7), into: &output)
        #expect(output == "#7")
    }
}
