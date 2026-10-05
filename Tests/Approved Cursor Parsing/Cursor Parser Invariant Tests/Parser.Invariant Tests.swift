#if Choice && Repetition && IteratorLeaves && Always && Map && FlatMap && Either
import Parser
import Checkpoint
import Always
import Either
import Cursor_Parser_Test_Support
import Cursor
import Testing

@Suite
struct `Parser.Invariant` {
    @Suite struct `Input Position` {}
    @Suite struct Algebra {}
    @Suite struct `Error Propagation` {}
    @Suite struct `Checkpoint Restore` {}
    @Suite struct Boundary {}
}

extension `Parser.Invariant`.`Input Position` {
    @Test
    func `Always does not advance input`() throws {
        let parser = Always<Int>.Parser<ArraySlice<UInt8>>(99)
        var input = ArraySlice<UInt8>([0x01, 0x02, 0x03])
        let checkpoint = input.checkpoint

        _ = try parser.parse(&input)

        #expect(input.checkpoint == checkpoint)
    }

    @Test
    func `Fail does not advance input`() throws {
        let parser = `Always Throwing Leaf`<ArraySlice<UInt8>, Int>(
            `Always Throwing Leaf Error`.predicateFailed(description: "test")
        )
        var input = ArraySlice<UInt8>([0x01, 0x02, 0x03])
        let checkpoint = input.checkpoint

        _ = try? parser.parse(&input)

        #expect(input.checkpoint == checkpoint)
    }

    @Test
    func `Peek does not advance input on success`() throws(any Swift.Error) {
        let parser = Parser::First.Element<ArraySlice<UInt8>>().peek()
        var input = ArraySlice<UInt8>([0x41, 0x42])
        let checkpoint = input.checkpoint

        _ = try parser.parse(&input)

        #expect(input.checkpoint == checkpoint)
    }

    @Test
    func `Not does not advance input on success`() throws(any Swift.Error) {
        let parser = Parser::First.Where<ArraySlice<UInt8>> { $0 == 0xFF }.not(rejected: { _ in true })
        var input = ArraySlice<UInt8>([0x01, 0x02])
        let checkpoint = input.checkpoint

        try parser.parse(&input)

        #expect(input.checkpoint == checkpoint)
    }

    @Test
    func `End does not advance input`() throws(any Swift.Error) {
        let parser = CursorParserTest.End()
        var input = ArraySlice<UInt8>([])
        let checkpoint = input.checkpoint

        try parser.parse(&input)

        #expect(input.checkpoint == checkpoint)
    }

    @Test
    func `First.Element advances exactly one position`() throws(any Swift.Error) {
        let parser = Parser::First.Element<ArraySlice<UInt8>>()
        var input = ArraySlice<UInt8>([0x0A, 0x0B, 0x0C])

        _ = try parser.parse(&input)

        #expect(input.first == 0x0B)
    }

    @Test
    func `Test.Take advances by count`() throws(any Swift.Error) {
        let parser = CursorParserTest.Take(4)
        var input = ArraySlice<UInt8>([0x0A, 0x0B, 0x0C, 0x0D, 0x0E])

        _ = try parser.parse(&input)

        #expect(input.first == 0x0E)
    }

    @Test
    func `Test.TakeWhile advances by matched prefix length`() throws(any Swift.Error) {
        let parser = CursorParserTest.TakeWhile { $0 < 0x05 }
        var input = ArraySlice<UInt8>([0x01, 0x02, 0x03, 0x04, 0x05, 0x06])

        let result = try parser.parse(&input)

        #expect(result.count == 4)
        #expect(input.first == 0x05)
    }

    @Test
    func `Rest advances to end`() throws {
        let parser = CursorParserTest.Rest()
        var input = ArraySlice<UInt8>([0x01, 0x02, 0x03])

        _ = try parser.parse(&input)

        #expect(input.isEmpty)
    }

    @Test
    func `OneOf restores position on failed first branch`() throws(any Swift.Error) {
        let parser = Parser::OneOf.Two(
            Parser::First.Where<ArraySlice<UInt8>> { $0 == 0xFF },
            Parser::First.Where<ArraySlice<UInt8>> { $0 == 0x42 }
        , rejectFirst: { _ in true }, rejectSecond: { _ in true })
        var input = ArraySlice<UInt8>([0x42, 0x43])

        _ = try parser.parse(&input)

        #expect(input.first == 0x43)
    }

    @Test
    func `Optional restores position on failure`() throws {
        let parser = Parser::Optionally<Parser::First.Where<ArraySlice<UInt8>>>(rejected: { _ in true }) {
            Parser::First.Where<ArraySlice<UInt8>> { $0 == 0xFF }
        }
        var input = ArraySlice<UInt8>([0x01, 0x02])
        let checkpoint = input.checkpoint

        _ = try parser.parse(&input)

        #expect(input.checkpoint == checkpoint)
    }
}

extension `Parser.Invariant`.Algebra {
    @Test
    func `map identity law`() throws(any Swift.Error) {
        let base = Parser::First.Element<ArraySlice<UInt8>>()
        let mapped = base.map { $0 }
        var input1 = ArraySlice<UInt8>([0x42])
        var input2 = ArraySlice<UInt8>([0x42])

        let result1 = try base.parse(&input1)
        let result2 = try mapped.parse(&input2)

        #expect(result1 == result2)
        #expect(input1.isEmpty == input2.isEmpty)
    }

    @Test
    func `map composition law`() throws(any Swift.Error) {
        let f: @Sendable (UInt8) -> Int = { Int($0) }
        let g: @Sendable (Int) -> String = { "\($0)" }

        let chained = Parser::First.Element<ArraySlice<UInt8>>().map(f).map(g)
        let composed = Parser::First.Element<ArraySlice<UInt8>>().map { g(f($0)) }

        var input1 = ArraySlice<UInt8>([0x0A])
        var input2 = ArraySlice<UInt8>([0x0A])

        let result1 = try chained.parse(&input1)
        let result2 = try composed.parse(&input2)

        #expect(result1 == result2)
        #expect(input1.isEmpty == input2.isEmpty)
    }

    @Test
    func `flatMap left identity`() throws(any Swift.Error) {
        let value: UInt8 = 0x05
        let f: @Sendable (UInt8) -> CursorParserTest.Take = { count in
            CursorParserTest.Take(Int(count))
        }

        let lhs = Always<UInt8>.Parser<ArraySlice<UInt8>>(value).flatMap(f)
        let rhs = f(value)

        var input1 = ArraySlice<UInt8>([0x01, 0x02, 0x03, 0x04, 0x05, 0x06])
        var input2 = ArraySlice<UInt8>([0x01, 0x02, 0x03, 0x04, 0x05, 0x06])

        let result1 = try lhs.parse(&input1)
        let result2 = try rhs.parse(&input2)

        #expect(result1.count == result2.count)
        #expect(input1.first == input2.first)
    }

    @Test
    func `flatMap right identity`() throws(any Swift.Error) {
        let base = Parser::First.Element<ArraySlice<UInt8>>()
        let lifted = base.flatMap { Always<UInt8>.Parser<ArraySlice<UInt8>>($0) }

        var input1 = ArraySlice<UInt8>([0x42, 0x43])
        var input2 = ArraySlice<UInt8>([0x42, 0x43])

        let result1 = try base.parse(&input1)
        let result2 = try lifted.parse(&input2)

        #expect(result1 == result2)
        #expect(input1.first == input2.first)
    }
}

extension `Parser.Invariant`.`Error Propagation` {
    @Test
    func `FlatMap tags upstream error as left`() throws {
        let parser = Parser::First.Element<ArraySlice<UInt8>>()
            .flatMap { _ in Always<Int>.Parser<ArraySlice<UInt8>>(0) }
        var input = ArraySlice<UInt8>([])

        #expect {
            try parser.parse(&input)
        } throws: { error in
            guard
                let either = error
                    as? Either<
                        Parser::EndOfInput.Error,
                        Never
                    >
            else { return false }
            return either.left != nil
        }
    }

    @Test
    func `FlatMap tags downstream error as right`() throws {
        let parser = Always<UInt8>.Parser<ArraySlice<UInt8>>(10)
            .flatMap { count -> CursorParserTest.Take in
                CursorParserTest.Take(Int(count))
            }
        var input = ArraySlice<UInt8>([0x01, 0x02])

        #expect {
            try parser.parse(&input)
        } throws: { error in
            guard
                let either = error
                    as? Either<
                        Never,
                        CursorParserTest.Take.Error
                    >
            else { return false }
            return either.right != nil
        }
    }

    @Test
    func `OneOf exposes error when all branches fail`() throws {
        let parser = Parser::OneOf.Two(
            Parser::First.Where<ArraySlice<UInt8>> { $0 == 0x41 },
            Parser::First.Where<ArraySlice<UInt8>> { $0 == 0x42 }
        , rejectFirst: { _ in true }, rejectSecond: { _ in true })
        var input = ArraySlice<UInt8>([0x43])

        #expect(throws: (any Swift.Error).self) {
            try parser.parse(&input)
        }
    }
}

extension `Parser.Invariant`.`Checkpoint Restore` {
    @Test
    func `OneOf.Two restores position on first-branch failure`() throws(any Swift.Error) {
        let parser = Parser::OneOf.Two(
            Parser::First.Where<ArraySlice<UInt8>> { $0 == 0xFF }.map { _ in "first" },
            Parser::First.Element<ArraySlice<UInt8>>().map { _ in "second" }
        , rejectFirst: { _ in true }, rejectSecond: { _ in true })
        var input = ArraySlice<UInt8>([0x42])

        let result = try parser.parse(&input)

        #expect(result == "second")
        #expect(input.isEmpty)
    }

    @Test
    func `Peek does not consume on success`() throws(any Swift.Error) {
        let parser = Parser::First.Element<ArraySlice<UInt8>>().peek()
        var input = ArraySlice<UInt8>([0x41, 0x42])
        let before = input.checkpoint

        _ = try parser.parse(&input)

        #expect(input.checkpoint == before)
    }

    @Test
    func `Not does not consume on success when inner fails`() throws(any Swift.Error) {
        let parser = Parser::First.Where<ArraySlice<UInt8>> { $0 == 0xFF }.not(rejected: { _ in true })
        var input = ArraySlice<UInt8>([0x01])
        let before = input.checkpoint

        try parser.parse(&input)

        #expect(input.checkpoint == before)
    }

    @Test
    func `Optional restores on inner failure`() throws {
        let parser = Parser::Optionally<Parser::First.Where<ArraySlice<UInt8>>>(rejected: { _ in true }) {
            Parser::First.Where<ArraySlice<UInt8>> { $0 == 0xFF }
        }
        var input = ArraySlice<UInt8>([0x01, 0x02, 0x03])
        let before = input.checkpoint

        let result: Parser::First.Where<ArraySlice<UInt8>>.Output? = try parser.parse(&input)

        #expect(result == nil)
        #expect(input.checkpoint == before)
    }
}

extension `Parser.Invariant`.Boundary {
    @Test
    func `empty input - First.Element fails`() throws {
        let parser = Parser::First.Element<ArraySlice<UInt8>>()
        var input = ArraySlice<UInt8>([])

        #expect(throws: Parser::EndOfInput.Error.self) {
            try parser.parse(&input)
        }
    }

    @Test
    func `empty input - Rest returns empty`() throws {
        let parser = CursorParserTest.Rest()
        var input = ArraySlice<UInt8>([])

        let result = try parser.parse(&input)

        #expect(result.isEmpty)
    }

    @Test
    func `empty input - End succeeds`() throws(any Swift.Error) {
        let parser = CursorParserTest.End()
        var input = ArraySlice<UInt8>([])

        try parser.parse(&input)
    }

    @Test
    func `single element - First.Element consumes all`() throws(any Swift.Error) {
        let parser = Parser::First.Element<ArraySlice<UInt8>>()
        var input = ArraySlice<UInt8>([0xFF])

        _ = try parser.parse(&input)

        #expect(input.isEmpty)
    }

    @Test
    func `many with large input`() throws(any Swift.Error) {
        let bytes = [UInt8](repeating: 0x41, count: 1000) + [0x42]
        let parser = CursorParserTest.TakeWhile { $0 == 0x41 }
        var input = ArraySlice<UInt8>(bytes)

        let result = try parser.parse(&input)

        #expect(result.count == 1000)
        #expect(input.first == 0x42)
    }
}

private enum `Always Throwing Leaf Error`: Swift.Error, Equatable {
    case predicateFailed(description: String)
}

private struct `Always Throwing Leaf`<Input, Output>: Parsing {
    public var body: Never {
        borrowing get {
            return fatalError("\(Self.self) is a leaf: implement its conformance requirements directly")
        }
    }

    let error: `Always Throwing Leaf Error`

    init(_ error: `Always Throwing Leaf Error`) {
        self.error = error
    }

    typealias Failure = `Always Throwing Leaf Error`

    func parse(_ input: inout Input) throws(Failure) -> Output {
        throw error
    }
}

private enum ClassifiedFailure: Swift.Error, Equatable { case mismatch, committed }

extension `Parser.Invariant`.Boundary {
    @Test func zeroMaximumDoesNotAttemptElementOrSeparator() throws {
        let element = Parser::Parser<ArraySlice<UInt8>, UInt8, ClassifiedFailure> { _ throws(ClassifiedFailure) in
            Issue.record("maximum zero must not execute the element")
            throw .committed
        }
        let separator = Parser::Parser<ArraySlice<UInt8>, Void, ClassifiedFailure> { _ throws(ClassifiedFailure) in
            Issue.record("maximum zero must not execute the separator")
            throw .committed
        }
        var input: ArraySlice<UInt8> = [1]
        let plain = Parser::Many(0...0, element, rejected: { $0 == .mismatch })
        #expect(try plain.parse(&input).isEmpty)
        let separated = Parser::Many<ArraySlice<UInt8>, Parser::Parser<ArraySlice<UInt8>, UInt8, ClassifiedFailure>>.Separated(
            0...0, element, separator: separator,
            rejected: { $0 == .mismatch }, separatorRejected: { $0 == .mismatch })
        #expect(try separated.parse(&input).isEmpty)
        #expect(input == [1])
    }

    @Test func committedRepetitionFailureRetainsConsumption() {
        let element = Parser::Parser<ArraySlice<UInt8>, UInt8, ClassifiedFailure> { input throws(ClassifiedFailure) in
            _ = input.popFirst()
            throw .committed
        }
        let many = Parser::Many(element, rejected: { $0 == .mismatch })
        var input: ArraySlice<UInt8> = [1, 2]
        #expect(throws: Parser::Many<ArraySlice<UInt8>, Parser::Parser<ArraySlice<UInt8>, UInt8, ClassifiedFailure>>.Error.element(.committed)) {
            try many.parse(&input)
        }
        #expect(input == [2])
    }

    @Test func choiceRetainsBothRejectionsAndRestoresFinalBranch() {
        let rejected = Parser::Parser<ArraySlice<UInt8>, UInt8, ClassifiedFailure> { input throws(ClassifiedFailure) in
            _ = input.popFirst()
            throw .mismatch
        }
        let choice = Parser::OneOf.Two(rejected, rejected,
            rejectFirst: { $0 == .mismatch }, rejectSecond: { $0 == .mismatch })
        var input: ArraySlice<UInt8> = [1, 2]
        do throws(Parser::OneOf.Two<Parser::Parser<ArraySlice<UInt8>, UInt8, ClassifiedFailure>, Parser::Parser<ArraySlice<UInt8>, UInt8, ClassifiedFailure>>.Error) { _ = try choice.parse(&input); Issue.record("Expected classified rejection") }
        catch {
            guard case .rejected(first: .mismatch, second: .mismatch) = error else {
                Issue.record("Expected both structured rejections"); return
            }
        }
        #expect(input == [1, 2])
    }

    @Test func committedChoiceDoesNotTryTheNextBranch() {
        let first = Parser::Parser<ArraySlice<UInt8>, UInt8, ClassifiedFailure> { input throws(ClassifiedFailure) in
            _ = input.popFirst()
            throw .committed
        }
        let next = Parser::Parser<ArraySlice<UInt8>, UInt8, ClassifiedFailure> { _ throws(ClassifiedFailure) in
            Issue.record("A committed failure must not try the next branch")
            return 0
        }
        let choice = Parser::OneOf.Two(first, next,
            rejectFirst: { $0 == .mismatch }, rejectSecond: { $0 == .mismatch })
        var input: ArraySlice<UInt8> = [1, 2]
        do throws(Parser::OneOf.Two<Parser::Parser<ArraySlice<UInt8>, UInt8, ClassifiedFailure>, Parser::Parser<ArraySlice<UInt8>, UInt8, ClassifiedFailure>>.Error) { _ = try choice.parse(&input); Issue.record("Expected committed failure") }
        catch { if case .first(.committed) = error {} else { Issue.record("Lost committed failure") } }
        #expect(input == [2])
    }
}
#endif
