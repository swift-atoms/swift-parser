import Parser
import Testing

@Suite
struct `Parser.Builder — var body declarative composition` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

struct Digit<Input: Collection.Slice.`Protocol`>: Sendable
where Input: Sendable, Input.Element == UInt8 {
}

enum __DigitError: Swift.Error, Sendable, Equatable {
    case expectedDigit
}
extension Digit { typealias Error = __DigitError }

extension Digit: Parser.`Protocol` {
    typealias Output = UInt8
    typealias Failure = Digit<Input>.Error

    func parse(_ input: inout Input) throws(Failure) -> UInt8 {
        guard input.startIndex < input.endIndex else { throw .expectedDigit }
        let byte = input[input.startIndex]
        guard byte >= 0x30, byte <= 0x39 else { throw .expectedDigit }
        input = input[input.index(after: input.startIndex)...]
        return byte - 0x30
    }
}

struct Expect<Input: Collection.Slice.`Protocol`>: Sendable
where Input: Sendable, Input.Element == UInt8 {
    let byte: UInt8
    init(_ byte: UInt8) { self.byte = byte }
}

enum __ExpectError: Swift.Error, Sendable, Equatable {
    case expected(UInt8)
}
extension Expect { typealias Error = __ExpectError }

extension Expect: Parser.`Protocol` {
    typealias Output = Void
    typealias Failure = Expect<Input>.Error

    func parse(_ input: inout Input) throws(Failure) {
        guard input.startIndex < input.endIndex,
            input[input.startIndex] == byte
        else { throw .expected(byte) }
        input = input[input.index(after: input.startIndex)...]
    }
}

struct Whitespace<Input: Collection.Slice.`Protocol`>: Sendable
where Input: Sendable, Input.Element == UInt8 {
}

extension Whitespace: Parser.`Protocol` {
    typealias Output = Void
    typealias Failure = Never

    func parse(_ input: inout Input) {
        while input.startIndex < input.endIndex,
            input[input.startIndex] == 0x20
        {
            input = input[input.index(after: input.startIndex)...]
        }
    }
}

struct CountRest<Input: Collection.Slice.`Protocol`>: Sendable
where Input: Sendable, Input.Element == UInt8 {
}

extension CountRest: Parser.`Protocol` {
    typealias Output = Int
    typealias Failure = Never

    func parse(_ input: inout Input) -> Int {
        var count = 0
        while input.startIndex < input.endIndex {
            input = input[input.index(after: input.startIndex)...]
            count += 1
        }
        return count
    }
}

struct SingleDigit<Input: Collection.Slice.`Protocol`>: Sendable
where Input: Sendable, Input.Element == UInt8 {
}

extension SingleDigit: Parser.`Protocol` {
    typealias Output = UInt8
    typealias Failure = Digit<Input>.Error

    var body: some Parser.`Protocol`<Input, UInt8, Digit<Input>.Error> {
        Digit<Input>()
    }
}

struct TwoDigits<Input: Collection.Slice.`Protocol`>: Sendable
where Input: Sendable, Input.Element == UInt8 {
}

enum __TwoDigitsError: Swift.Error, Sendable, Equatable {
    case first
    case second
}
extension TwoDigits { typealias Error = __TwoDigitsError }

extension TwoDigits: Parser.`Protocol` {
    typealias Output = (UInt8, UInt8)
    typealias Failure = TwoDigits<Input>.Error

    var body: some Parser.`Protocol`<Input, (UInt8, UInt8), TwoDigits<Input>.Error> {
        Parser.Take.Sequence {
            Digit<Input>()
            Digit<Input>()
        }
        .error.map { either -> TwoDigits<Input>.Error in
            switch either {
            case .left: .first
            case .right: .second
            }
        }
    }
}

struct SkipThenDigit<Input: Collection.Slice.`Protocol`>: Sendable
where Input: Sendable, Input.Element == UInt8 {
}

extension SkipThenDigit: Parser.`Protocol` {
    typealias Output = UInt8
    typealias Failure = Digit<Input>.Error

    var body: some Parser.`Protocol`<Input, UInt8, Digit<Input>.Error> {
        Parser.Take.Sequence {
            Whitespace<Input>()
            Digit<Input>()
        }
        .error.map { $0.value }
    }
}

struct DigitThenSkip<Input: Collection.Slice.`Protocol`>: Sendable
where Input: Sendable, Input.Element == UInt8 {
}

extension DigitThenSkip: Parser.`Protocol` {
    typealias Output = UInt8
    typealias Failure = Digit<Input>.Error

    var body: some Parser.`Protocol`<Input, UInt8, Digit<Input>.Error> {
        Parser.Take.Sequence {
            Digit<Input>()
            Whitespace<Input>()
        }
        .error.map { $0.value }
    }
}

struct Version: Sendable, Equatable {
    let major: UInt8
    let minor: UInt8
    let patch: UInt8

    init(_ major: UInt8, _ minor: UInt8, _ patch: UInt8) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
}

extension Version {
    enum Error: Swift.Error, Sendable, Equatable {
        case expectedMajor
        case expectedDot
        case expectedMinor
        case expectedPatch
    }
}

extension Version {
    struct Parser<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == UInt8 {
    }
}

extension Version.Parser: Parser.Parser.`Protocol` {
    typealias Output = Version
    typealias Failure = Version.Error

    var body: some Parser.Parser.`Protocol`<Input, Version, Version.Error> {
        Parser.Parser.Take.Sequence {
            Digit<Input>()
            Expect<Input>(0x2E)
            Digit<Input>()
            Expect<Input>(0x2E)
            Digit<Input>()
        }
        .map { major, minor, patch in
            Version(major, minor, patch)
        }
        .error.map { either -> Version.Error in

            switch either {
            case .right:
                return .expectedPatch

            case .left(let e4):
                switch e4 {
                case .right:
                    return .expectedDot

                case .left(let e3):
                    switch e3 {
                    case .right:
                        return .expectedMinor

                    case .left(let e2):
                        switch e2 {
                        case .right:
                            return .expectedDot

                        case .left:
                            return .expectedMajor
                        }
                    }
                }
            }
        }
    }
}

struct SkipWhitespaceCountRest<Input: Collection.Slice.`Protocol`>: Sendable
where Input: Sendable, Input.Element == UInt8 {
}

extension SkipWhitespaceCountRest: Parser.`Protocol` {
    typealias Output = Int
    typealias Failure = Never

    var body: some Parser.`Protocol`<Input, Int, Never> {
        Parser.Take.Sequence {
            Whitespace<Input>()
            CountRest<Input>()
        }
        .error.map { either -> Never in
            switch either {
            case .left(let never): switch never {}
            case .right(let never): switch never {}
            }
        }
    }
}

struct WhitespaceVersion<Input: Collection.Slice.`Protocol`>: Sendable
where Input: Sendable, Input.Element == UInt8 {
}

extension WhitespaceVersion: Parser.`Protocol` {
    typealias Output = Version
    typealias Failure = Version.Error

    var body: some Parser.`Protocol`<Input, Version, Version.Error> {
        Parser.Take.Sequence {
            Whitespace<Input>()
            Version.Parser<Input>()
        }
        .error.map { $0.value }
    }
}

struct TwoDigitNumber<Input: Collection.Slice.`Protocol`>: Sendable
where Input: Sendable, Input.Element == UInt8 {
}

enum __TwoDigitNumberError: Swift.Error, Sendable, Equatable {
    case expectedDigit
}
extension TwoDigitNumber { typealias Error = __TwoDigitNumberError }

extension TwoDigitNumber: Parser.`Protocol` {
    typealias Output = Int
    typealias Failure = TwoDigitNumber<Input>.Error

    var body: some Parser.`Protocol`<Input, Int, TwoDigitNumber<Input>.Error> {
        Parser.Take.Sequence {
            Digit<Input>()
            Digit<Input>()
        }
        .map { tens, ones in Int(tens) * 10 + Int(ones) }
        .error.map { _ -> TwoDigitNumber<Input>.Error in .expectedDigit }
    }
}

struct BothVoid<Input: Collection.Slice.`Protocol`>: Sendable
where Input: Sendable, Input.Element == UInt8 {
}

extension BothVoid: Parser.`Protocol` {
    typealias Output = Void
    typealias Failure = Either<Expect<Input>.Error, Expect<Input>.Error>

    var body: some Parser.`Protocol`<Input, Void, Either<Expect<Input>.Error, Expect<Input>.Error>>
    {
        Expect<Input>(0x2E)
        Expect<Input>(0x2E)
    }
}

struct BothVoidThenDigit<Input: Collection.Slice.`Protocol`>: Sendable
where Input: Sendable, Input.Element == UInt8 {
}

extension BothVoidThenDigit: Parser.`Protocol` {
    typealias Output = UInt8
    typealias Failure = Either<Either<Expect<Input>.Error, Expect<Input>.Error>, Digit<Input>.Error>

    var body:
        some Parser.`Protocol`<
            Input, UInt8,
            Either<Either<Expect<Input>.Error, Expect<Input>.Error>, Digit<Input>.Error>
        >
    {
        Expect<Input>(0x2E)
        Expect<Input>(0x2E)
        Digit<Input>()
    }
}

extension `Parser.Builder — var body declarative composition`.Unit {
    @Test
    func `leaf parser has Body == Never`() throws(any Swift.Error) {
        let parser = Digit<Parser.Test.Input>()
        var input = Parser.Test.Input([0x35])

        let result = try parser.parse(&input)

        #expect(result == 5)
        #expect(type(of: parser).Body.self == Never.self)
    }

    @Test
    func `single parser pass-through via var body`() throws(any Swift.Error) {
        let parser = SingleDigit<Parser.Test.Input>()
        var input = Parser.Test.Input([0x37])

        let result = try parser.parse(&input)

        #expect(result == 7)
    }

    @Test
    func `two values compose into tuple`() throws(any Swift.Error) {
        let parser = TwoDigits<Parser.Test.Input>()
        var input = Parser.Test.Input([0x31, 0x32])

        let (a, b) = try parser.parse(&input)

        #expect(a == 1)
        #expect(b == 2)
    }

    @Test
    func `void output from first parser is skipped`() throws(any Swift.Error) {
        let parser = SkipThenDigit<Parser.Test.Input>()
        var input = Parser.Test.Input(utf8: "  5")

        let result = try parser.parse(&input)

        #expect(result == 5)
    }

    @Test
    func `void output from second parser is skipped`() throws(any Swift.Error) {
        let parser = DigitThenSkip<Parser.Test.Input>()
        var input = Parser.Test.Input(utf8: "5  ")

        let result = try parser.parse(&input)

        #expect(result == 5)
    }

    @Test
    func `five parsers flatten with void-skipping and tuple flattening`() throws(any Swift.Error) {
        let parser = Version.Parser<Parser.Test.Input>()
        var input = Parser.Test.Input(utf8: "1.2.3")

        let version = try parser.parse(&input)

        #expect(version == Version(1, 2, 3))
    }

    @Test
    func `output mapping transforms parsed tuple`() throws(any Swift.Error) {
        let parser = TwoDigitNumber<Parser.Test.Input>()
        var input = Parser.Test.Input(utf8: "42")

        let result = try parser.parse(&input)

        #expect(result == 42)
    }

    @Test
    func `error mapping converts Either tree to domain error`() {
        let parser = TwoDigits<Parser.Test.Input>()
        var input = Parser.Test.Input(utf8: "1x")

        #expect(throws: TwoDigits<Parser.Test.Input>.Error.second) {
            try parser.parse(&input)
        }
    }

    @Test
    func `infallible body produces Never failure`() {
        let parser = SkipWhitespaceCountRest<Parser.Test.Input>()
        var input = Parser.Test.Input(utf8: "   hello")

        let count = parser.parse(&input)

        #expect(count == 5)
    }

    @Test
    func `nested declarative parsers compose`() throws(any Swift.Error) {
        let parser = WhitespaceVersion<Parser.Test.Input>()
        var input = Parser.Test.Input(utf8: "  1.0.9")

        let version = try parser.parse(&input)

        #expect(version == Version(1, 0, 9))
    }

    @Test
    func `default parse delegates to body`() throws(any Swift.Error) {
        let parser = Version.Parser<Parser.Test.Input>()
        var input1 = Parser.Test.Input(utf8: "3.1.4")
        var input2 = Parser.Test.Input(utf8: "3.1.4")

        let fromBody = try parser.body.parse(&input1)
        let fromParse = try parser.parse(&input2)

        #expect(fromBody == fromParse)
    }

    @Test
    func `input is consumed correctly through var body`() throws(any Swift.Error) {
        let parser = SkipThenDigit<Parser.Test.Input>()
        var input = Parser.Test.Input(utf8: " 7rest")

        _ = try parser.parse(&input)

        #expect(input.first == UInt8(ascii: "r"))
    }

    @Test
    func `version parser consumes exactly five bytes`() throws(any Swift.Error) {
        let parser = Version.Parser<Parser.Test.Input>()
        var input = Parser.Test.Input(utf8: "1.2.3 extra")

        _ = try parser.parse(&input)

        #expect(input.first == UInt8(ascii: " "))
    }

    @Test
    func `version parser boundary values`() throws(any Swift.Error) {
        let parser = Version.Parser<Parser.Test.Input>()
        var input = Parser.Test.Input(utf8: "0.0.0")

        let version = try parser.parse(&input)

        #expect(version == Version(0, 0, 0))
    }

    @Test
    func `version parser max single digits`() throws(any Swift.Error) {
        let parser = Version.Parser<Parser.Test.Input>()
        var input = Parser.Test.Input(utf8: "9.9.9")

        let version = try parser.parse(&input)

        #expect(version == Version(9, 9, 9))
    }

    @Test
    func `both-Void pair as the only two statements resolves the tie`() throws(any Swift.Error) {
        let parser = BothVoid<Parser.Test.Input>()
        var input = Parser.Test.Input(utf8: "..rest")

        try parser.parse(&input)

        #expect(input.first == UInt8(ascii: "r"))
    }

    @Test
    func `both-Void pair mid-chain composes forward to a value`() throws(any Swift.Error) {
        let parser = BothVoidThenDigit<Parser.Test.Input>()
        var input = Parser.Test.Input(utf8: "..5rest")

        let value = try parser.parse(&input)

        #expect(value == 5)
        #expect(input.first == UInt8(ascii: "r"))
    }
}

extension `Parser.Builder — var body declarative composition`.`Edge Case` {
    @Test
    func `single pass-through body propagates failure`() {
        let parser = SingleDigit<Parser.Test.Input>()
        var input = Parser.Test.Input(utf8: "x")

        #expect(throws: Digit<Parser.Test.Input>.Error.expectedDigit) {
            try parser.parse(&input)
        }
    }

    @Test
    func `single pass-through body fails on empty input`() {
        let parser = SingleDigit<Parser.Test.Input>()
        var input = Parser.Test.Input([])

        #expect(throws: Digit<Parser.Test.Input>.Error.expectedDigit) {
            try parser.parse(&input)
        }
    }

    @Test
    func `two digits first failure maps to domain error`() {
        let parser = TwoDigits<Parser.Test.Input>()
        var input = Parser.Test.Input(utf8: "x")

        #expect(throws: TwoDigits<Parser.Test.Input>.Error.first) {
            try parser.parse(&input)
        }
    }

    @Test
    func `two digits second failure maps to domain error`() {
        let parser = TwoDigits<Parser.Test.Input>()
        var input = Parser.Test.Input(utf8: "1x")

        #expect(throws: TwoDigits<Parser.Test.Input>.Error.second) {
            try parser.parse(&input)
        }
    }

    @Test
    func `two digits empty input maps to first`() {
        let parser = TwoDigits<Parser.Test.Input>()
        var input = Parser.Test.Input([])

        #expect(throws: TwoDigits<Parser.Test.Input>.Error.first) {
            try parser.parse(&input)
        }
    }

    @Test
    func `version parser reports expectedMajor on empty`() {
        let parser = Version.Parser<Parser.Test.Input>()
        var input = Parser.Test.Input([])

        #expect(throws: Version.Error.expectedMajor) {
            try parser.parse(&input)
        }
    }

    @Test
    func `version parser reports expectedDot after major`() {
        let parser = Version.Parser<Parser.Test.Input>()
        var input = Parser.Test.Input(utf8: "1x")

        #expect(throws: Version.Error.expectedDot) {
            try parser.parse(&input)
        }
    }

    @Test
    func `version parser reports expectedMinor after first dot`() {
        let parser = Version.Parser<Parser.Test.Input>()
        var input = Parser.Test.Input(utf8: "1.x")

        #expect(throws: Version.Error.expectedMinor) {
            try parser.parse(&input)
        }
    }

    @Test
    func `version parser reports expectedPatch after second dot`() {
        let parser = Version.Parser<Parser.Test.Input>()
        var input = Parser.Test.Input(utf8: "1.2.x")

        #expect(throws: Version.Error.expectedPatch) {
            try parser.parse(&input)
        }
    }

    @Test
    func `version parser reports expectedDot on truncated input`() {
        let parser = Version.Parser<Parser.Test.Input>()
        var input = Parser.Test.Input(utf8: "1")

        #expect(throws: Version.Error.expectedDot) {
            try parser.parse(&input)
        }
    }

    @Test
    func `nested declarative parser propagates inner errors`() {
        let parser = WhitespaceVersion<Parser.Test.Input>()
        var input = Parser.Test.Input(utf8: "  1.2.x")

        #expect(throws: Version.Error.expectedPatch) {
            try parser.parse(&input)
        }
    }

    @Test
    func `nested declarative parser fails on empty after whitespace`() {
        let parser = WhitespaceVersion<Parser.Test.Input>()
        var input = Parser.Test.Input(utf8: "   ")

        #expect(throws: Version.Error.expectedMajor) {
            try parser.parse(&input)
        }
    }

    @Test
    func `infallible parser returns zero on empty input`() {
        let parser = SkipWhitespaceCountRest<Parser.Test.Input>()
        var input = Parser.Test.Input([])

        let count = parser.parse(&input)

        #expect(count == 0)
    }

    @Test
    func `infallible parser counts only non-whitespace`() {
        let parser = SkipWhitespaceCountRest<Parser.Test.Input>()
        var input = Parser.Test.Input(utf8: "     ")

        let count = parser.parse(&input)

        #expect(count == 0)
    }

    @Test
    func `void-skip left with empty input delegates error`() {
        let parser = SkipThenDigit<Parser.Test.Input>()
        var input = Parser.Test.Input([])

        #expect(throws: Digit<Parser.Test.Input>.Error.expectedDigit) {
            try parser.parse(&input)
        }
    }

    @Test
    func `void-skip left with only whitespace delegates error`() {
        let parser = SkipThenDigit<Parser.Test.Input>()
        var input = Parser.Test.Input(utf8: "   ")

        #expect(throws: Digit<Parser.Test.Input>.Error.expectedDigit) {
            try parser.parse(&input)
        }
    }

    @Test
    func `void-skip right preserves value with no trailing whitespace`() throws(any Swift.Error) {
        let parser = DigitThenSkip<Parser.Test.Input>()
        var input = Parser.Test.Input(utf8: "9")

        let result = try parser.parse(&input)

        #expect(result == 9)
    }

    @Test
    func `output mapping fails on non-digit`() {
        let parser = TwoDigitNumber<Parser.Test.Input>()
        var input = Parser.Test.Input(utf8: "x")

        #expect(throws: TwoDigitNumber<Parser.Test.Input>.Error.expectedDigit) {
            try parser.parse(&input)
        }
    }

    @Test
    func `output mapping fails on single digit`() {
        let parser = TwoDigitNumber<Parser.Test.Input>()
        var input = Parser.Test.Input(utf8: "4x")

        #expect(throws: TwoDigitNumber<Parser.Test.Input>.Error.expectedDigit) {
            try parser.parse(&input)
        }
    }
}
