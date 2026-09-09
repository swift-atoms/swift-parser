import Either
import Parser
import Testing

@Suite
struct `Parser maps preserve failure types and transfer transformed outputs` {

    @Test
    func `nonthrowing stages remain exactly nonthrowing`() {
        let parser = Incremented()
        requireFailure(parser, Never.self)

        var input = 41
        let output = parser.parse(&input)

        #expect(output == 42)
    }

    @Test
    func `fallible upstream with nonthrowing transform preserves upstream failure`() {
        let parser = IncrementedFallibleUpstream()
        requireFailure(parser, UpstreamFailure.self)

        var input = 0
        #expect(throws: UpstreamFailure.failed) {
            try parser.parse(&input)
        }
    }

    @Test
    func `nonthrowing upstream with throwing transform exposes only transform failure`() {
        let parser = ThrowingTransform()
        requireFailure(parser, TransformFailure.self)

        var input = 0
        #expect(throws: TransformFailure.failed) {
            try parser.parse(&input)
        }
    }

    @Test
    func `two fallible stages use Either`() {
        let upstream = FallibleUpstreamThrowingTransform()
        requireFailure(
            upstream,
            Either<UpstreamFailure, TransformFailure>.self
        )

        var upstreamInput = 0
        #expect {
            try upstream.parse(&upstreamInput)
        } throws: { error in
            guard
                let failure = error
                    as? Either<UpstreamFailure, TransformFailure>
            else { return false }
            return failure.left == .failed
        }

        let transform = FallibleUpstreamFailingTransform()
        requireFailure(
            transform,
            Either<UpstreamFailure, TransformFailure>.self
        )
        var transformInput = 0
        #expect {
            try transform.parse(&transformInput)
        } throws: { error in
            guard
                let failure = error
                    as? Either<UpstreamFailure, TransformFailure>
            else { return false }
            return failure.right == .failed
        }
    }

    @Test
    func `throws Never transform remains exactly nonthrowing`() {
        let parser = IncrementedByNeverThrowingFunction()
        requireFailure(parser, Never.self)

        var input = 41
        let output = parser.parse(&input)

        #expect(output == 42)
    }

    @Test
    func `fallible upstream with throws Never transform preserves upstream failure`() {
        let parser = FallibleUpstreamNeverThrowingFunction()
        requireFailure(parser, UpstreamFailure.self)
    }

    @Test
    func `constructing a parser with a throwing transform is nonthrowing`() {
        _ = ThrowingTransform().body
    }

    @Test
    func `Map consumes noncopyable nonescapable output`() {
        let parser = IncrementedScopedToken()
        requireFailure(parser, Never.self)

        var input = 41
        let output = parser.parse(&input)

        #expect(output == 42)
    }

    @Test
    func `Map produces noncopyable output`() {
        let parser = IncrementedIntoLinearResult()
        requireFailure(parser, Never.self)

        var input = 41
        let output = parser.parse(&input)

        #expect(output.value == 42)
    }
}

private func requireFailure<
    P: Parsing & ~Copyable,
    Failure: Swift.Error
>(
    _ parser: borrowing P,
    _: Failure.Type
)
where
    P.Input: ~Copyable & ~Escapable,
    P.Output: ~Copyable & ~Escapable,
    P.Failure == Failure
{}

private func increment(_ value: consuming Int) throws(Never) -> Int {
    value + 1
}

private struct Incremented: Parsing {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = Never

    var body: some Parsing<Int, Int, Never> {
        Succeed().map { $0 + 1 }
    }
}

private struct IncrementedFallibleUpstream: Parsing {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = UpstreamFailure

    var body: some Parsing<Int, Int, UpstreamFailure> {
        Fail().map { $0 + 1 }
    }
}

private struct ThrowingTransform: Parsing {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = TransformFailure

    var body: some Parsing<Int, Int, TransformFailure> {
        Succeed().map {
            (_: consuming Int) throws(TransformFailure) -> Int in
            throw .failed
        }
    }
}

private struct FallibleUpstreamThrowingTransform: Parsing {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = Either<UpstreamFailure, TransformFailure>

    var body: some Parsing<
        Int,
        Int,
        Either<UpstreamFailure, TransformFailure>
    > {
        Fail().map {
            (value: consuming Int) throws(TransformFailure) -> Int in
            value + 1
        }
    }
}

private struct FallibleUpstreamFailingTransform: Parsing {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = Either<UpstreamFailure, TransformFailure>

    var body: some Parsing<
        Int,
        Int,
        Either<UpstreamFailure, TransformFailure>
    > {
        FallibleSucceed().map {
            (_: consuming Int) throws(TransformFailure) -> Int in
            throw .failed
        }
    }
}

private struct IncrementedByNeverThrowingFunction: Parsing {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = Never

    var body: some Parsing<Int, Int, Never> {
        Succeed().map(increment)
    }
}

private struct FallibleUpstreamNeverThrowingFunction: Parsing {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = UpstreamFailure

    var body: some Parsing<Int, Int, UpstreamFailure> {
        Fail().map(increment)
    }
}

private struct IncrementedScopedToken: Parsing {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = Never

    var body: some Parsing<Int, Int, Never> {
        Linear().map { token in token.value + 1 }
    }
}

private struct IncrementedIntoLinearResult: Parsing {
    typealias Input = Int
    typealias Output = LinearResult
    typealias Failure = Never

    var body: some Parsing<Int, LinearResult, Never> {
        Succeed().map { LinearResult(value: $0 + 1) }
    }
}

private enum UpstreamFailure: Swift.Error, Equatable {
    case failed
}

private enum TransformFailure: Swift.Error, Equatable {
    case failed
}

private struct Succeed: Parsing {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = Never

    borrowing func parse(_ input: inout Int) -> Int {
        input
    }
}

private struct Fail: Parsing {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = UpstreamFailure

    borrowing func parse(
        _ input: inout Int
    ) throws(UpstreamFailure) -> Int {
        throw .failed
    }
}

private struct FallibleSucceed: Parsing {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = UpstreamFailure

    borrowing func parse(
        _ input: inout Int
    ) throws(UpstreamFailure) -> Int {
        input
    }
}

private struct ScopedToken: ~Copyable, ~Escapable {
    let value: Int
}

private struct LinearResult: ~Copyable {
    let value: Int
}

private struct Linear: Parsing {
    typealias Input = Int
    typealias Output = ScopedToken
    typealias Failure = Never

    @_lifetime(&input)
    borrowing func parse(_ input: inout Int) -> ScopedToken {
        ScopedToken(value: input)
    }
}

@Suite
struct `Parser maps transform values read from a nonescapable cursor` {

    @Test
    func `map transforms a value read from a nonescapable cursor`() throws(any Swift.Error) {
        let bytes: [UInt8] = [41]
        var cursor = Cursor(bytes.span)
        let value = try Successor().parse(&cursor)
        let end = cursor.index
        #expect(value == 42)
        #expect(end == 1)
    }
}

private struct Successor: Parsing {
    typealias Failure = ByteMismatch

    var body: some Parsing<Cursor, UInt8, ByteMismatch> {
        ByteValue().map { $0 &+ 1 }
    }
}
private struct Cursor: ~Escapable {
    var span: Span<UInt8>
    var index: Int

    @_lifetime(copy span)
    init(_ span: Span<UInt8>) {
        self.span = span
        self.index = 0
    }
}

private enum ByteMismatch: Swift.Error, Equatable {
    case expected(UInt8)
    case endOfInput
}

private struct ByteMarker: Parsing {
    let expected: UInt8

    init(_ expected: UInt8) {
        self.expected = expected
    }

    borrowing func parse(_ input: inout Cursor) throws(ByteMismatch) {
        guard input.index < input.span.count else { throw .endOfInput }
        guard input.span[input.index] == expected else { throw .expected(expected) }
        input.index += 1
    }
}

private struct ByteValue: Parsing {
    borrowing func parse(_ input: inout Cursor) throws(ByteMismatch) -> UInt8 {
        guard input.index < input.span.count else { throw .endOfInput }
        let byte = input.span[input.index]
        input.index += 1
        return byte
    }
}
