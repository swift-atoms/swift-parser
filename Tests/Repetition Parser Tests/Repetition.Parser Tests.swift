#if Repetition
    import Parser
    import Testing

    private enum Rejected: Swift.Error { case mismatch }
    private enum Fatal: Swift.Error, Equatable { case unavailable }
    private struct Step: Parsing, ~Copyable {
    }

    extension Step {
        typealias Input = Substring

        typealias Output = Character

        typealias Failure = Either<Rejected, Fatal>
    }

    extension Step {
        func parse(_ input: inout Substring) throws(Failure) -> Character {
            guard let value = input.popFirst() else { throw .left(.mismatch) }
            if value == "!" { throw .right(.unavailable) }
            guard value.isNumber else { throw .left(.mismatch) }
            return value
        }
    }

    enum `Repetition.Parser Tests` {}

    extension `Repetition.Parser Tests` {
        @Suite struct `Repetition Parser Tests` {
            @Test func `rejected iteration is restored`() throws {
                let bounds: ClosedRange<Cardinal> = 2...5
                let parser: ClosedRange<Cardinal>.Parser<Step, Rejected, Fatal> = bounds.parser { Step() }
                var input: Substring = "12xrest"
                #expect(try parser.parse(&input) == ["1", "2"])
                #expect(input == "xrest")
            }
            @Test func `fatal errors propagate rather than stopping`() {
                let bounds: PartialRangeFrom<Cardinal> = 0...
                let parser = bounds.parser { Step() }
                var input: Substring = "12!rest"
                #expect(throws: Either<Repetition<PartialRangeFrom<Cardinal>, Step>.Error, Fatal>.right(.unavailable)) {
                    _ = try parser.parse(&input)
                }
                #expect(input == "rest")
            }
            @Test func `minimum failure restores only the rejected iteration`() {
                let bounds: ClosedRange<Cardinal> = 2...5
                let parser = bounds.parser { Step() }
                var input: Substring = "1xrest"
                #expect(throws: Either<Repetition<ClosedRange<Cardinal>, Step>.Error, Fatal>.left(.insufficient(actual: 1))) {
                    _ = try parser.parse(&input)
                }
                #expect(input == "xrest")
            }
            @Test func `no progress is an error`() {
                let bounds: PartialRangeFrom<Cardinal> = 0...
                let parser = bounds.parser {
                    Parser<Substring, Int, Either<Rejected, Fatal>> { _ in 1 }
                }
                var input: Substring = "abc"
                do {
                    _ = try parser.parse(&input)
                    Issue.record("Expected no-progress error")
                } catch {
                    switch error {
                    case .left(.noProgress): break
                    default: Issue.record("Unexpected failure")
                    }
                }
                #expect(input == "abc")
            }
            @Test func `upper bound does not probe the next element`() throws {
                let bounds: PartialRangeThrough<Cardinal> = ...2
                let parser = bounds.parser { Step() }
                var input: Substring = "12!"
                #expect(try parser.parse(&input) == ["1", "2"])
                #expect(input == "!")
            }
            @Test func `exclusive and empty bounds are handled without underflow`() throws {
                let bounds: Range<Cardinal> = 1..<3
                var input: Substring = "123"
                #expect(try bounds.parser { Step() }.parse(&input) == ["1", "2"])
                #expect(input == "3")
                let empty: PartialRangeUpTo<Cardinal> = ..<0
                #expect(throws: Either<Repetition<PartialRangeUpTo<Cardinal>, Step>.Error, Fatal>.left(.emptyBounds)) {
                    _ = try empty.parser { Step() }.parse(&input)
                }
                #expect(input == "3")
            }
        }
    }

    private struct ScopedInput: Restorable, ~Copyable, ~Escapable {
        let values: Span<Int>
        var position: Int = 0
        @_lifetime(copy values)
        init(_ values: Span<Int>) { self.values = values }
    }

    extension ScopedInput {
        var checkpoint: Int { position }

        mutating func seek(to checkpoint: Int) { position = checkpoint }
    }

    extension `Repetition.Parser Tests`.`Repetition Parser Tests` {
        @Test func `scoped noncopyable input restores its checkpoint`() throws {
            let values = [1, 2, -1, 4]
            var input = ScopedInput(values.span)
            let bounds: PartialRangeFrom<Cardinal> = 0...
            let parser = bounds.parser {
                Parser<ScopedInput, Int, Either<Rejected, Fatal>> { input throws(Either<Rejected, Fatal>) in
                    guard input.position < input.values.count else { throw .left(.mismatch) }
                    let value = input.values[input.position]
                    input.position += 1
                    guard value > 0 else { throw .left(.mismatch) }
                    return value
                }
            }
            #expect(try parser.parse(&input) == [1, 2])
            #expect(input.position == 2)
        }
    }

    extension `Repetition.Parser Tests`.`Repetition Parser Tests` {
        @Test func `array slice restores rejected element`() throws {
            let bounds: PartialRangeFrom<Cardinal> = 0...
            let parser = bounds.parser {
                Parser<ArraySlice<Int>, Int, Either<Rejected, Fatal>> { input throws(Either<Rejected, Fatal>) in
                    guard let value = input.popFirst(), value >= 0 else { throw .left(.mismatch) }
                    return value
                }
            }
            var input: ArraySlice<Int> = [1, -1, 2]
            #expect(try parser.parse(&input) == [1])
            #expect(input == [-1, 2])
        }
    }

    private final class Probe { var destroyed = 0 }
    private struct OwnedStep: Parsing, ~Copyable {
        let probe: Probe
        deinit { probe.destroyed += 1 }
    }

    extension OwnedStep {
        typealias Input = Substring

        typealias Output = Character

        typealias Failure = Either<Rejected, Fatal>
    }

    extension OwnedStep {
        func parse(_ input: inout Substring) throws(Failure) -> Character { try Step().parse(&input) }
    }

    extension `Repetition.Parser Tests`.`Repetition Parser Tests` {
        @Test func `a builder counts whole compositions and restores partial rejection`() throws {
            let bounds: PartialRangeFrom<Cardinal> = 0...
            let parser = bounds.parser(for: Substring.self) {
                Step()
                Step()
            }
            var input: Substring = "123x"
            let result = try parser.parse(&input)
            #expect(result.count == 1)
            #expect(result[0].0 == "1")
            #expect(result[0].1 == "2")
            #expect(input == "3x")
        }
        @Test func `the operation owner is borrowed and destroyed once`() throws {
            let probe = Probe()
            let bounds: PartialRangeFrom<Cardinal> = 0...
            var input: Substring = "1x"
            do {
                let parser = bounds.parser { OwnedStep(probe: probe) }
                #expect(try parser.parse(&input) == ["1"])
                #expect(try parser.parse(&input).isEmpty)
                #expect(probe.destroyed == 0)
            }
            #expect(probe.destroyed == 1)
        }
    }
#endif
