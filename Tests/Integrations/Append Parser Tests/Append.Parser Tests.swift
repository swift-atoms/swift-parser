#if Append
import Append
import Either
import Parser
import Testing

@Suite
struct `Append parser adapters` {

    @Test
    func `tuple operation parses in order without try`() {
        let append = Append<Int, Int, (Int, Int), Never>()
        let number = Parser<Int, Int, Never> { input in
            input += 1
            return input
        }
        let parser = append.parser(number, number)
        requireCopyable(parser)
        var input = 0
        let result = parser.parse(&input)
        #expect(result.0 == 1)
        #expect(result.1 == 2)
        #expect(input == 2)
    }

    @Test(arguments: [1, 2, 3])
    func `distinct stage failures preserve consumption and skip later work`(_ stage: Int) {
        var calls = 0
        let append = Append<Int, Int, Int, AppendError> {
            (head, last) throws(AppendError) in
            calls += 1
            if stage == 3 { throw .rejected }
            return head + last
        }
        let first = Parser<Int, Int, FirstError> {
            (input: inout Int) throws(FirstError) in
            input += 1
            if stage == 1 { throw .rejected }
            return input
        }
        let second = Parser<Int, Int, SecondError> {
            (input: inout Int) throws(SecondError) in
            input += 1
            if stage == 2 { throw .rejected }
            return input
        }
        let parser = append.parser(first, second)
        var input = 0
        do throws(Either<Either<FirstError, SecondError>, AppendError>) {
            _ = try parser.parse(&input)
            Issue.record("Expected stage failure")
        } catch {
            switch error {
            case .left(.left(.rejected)): #expect(stage == 1)
            case .left(.right(.rejected)): #expect(stage == 2)
            case .right(.rejected): #expect(stage == 3)
            }
        }
        #expect(input == (stage == 1 ? 1 : 2))
        #expect(calls == (stage == 3 ? 1 : 0))
    }

    @Test
    func `shared error remains the exact failure type`() {
        let append = Append<Int, Int, Int, AppendError> {
            (_, _) throws(AppendError) in throw .rejected
        }
        let number = Parser<Int, Int, AppendError> {
            (input: inout Int) throws(AppendError) in
            input += 1
            return input
        }
        let parser = append.parser(number, number)
        var input = 0
        do throws(AppendError) {
            _ = try parser.parse(&input)
            Issue.record("Expected append failure")
        } catch {
            #expect(error == .rejected)
        }
        #expect(input == 2)
    }

    @Test
    func `linear parsers transfer operands over scoped input and remain reusable`() {
        let lifetime = Lifetime()
        let append = Append<Owned, Owned, Owned, Never> {
            (first: consuming Owned, second: consuming Owned) in
            Owned(value: first.value + second.value)
        }
        let parser = append.parser(Reader(lifetime: lifetime), Reader(lifetime: lifetime))
        let values = [1, 2, 3, 4]
        var input = Cursor(values.span)
        let first = parser.parse(&input)
        let second = parser.parse(&input)
        #expect(first.value == 3)
        #expect(second.value == 7)
        #expect(input.index == 4)
        #expect(lifetime.destroyed == 0)
        discard(parser)
        #expect(lifetime.destroyed == 2)
    }

    @Test
    func `final output can borrow from the stored append operation`() {
        let storage = [10, 20]
        let append = Append<Int, Int, Span<Int>, Never> { _, _ in storage.span }
        let number = Parser<Int, Int, Never> { input in input += 1; return input }
        let parser = append.parser(number, number)
        var input = 0
        let result = parser.parse(&input)
        #expect(result[0] == 10)
        #expect(result[1] == 20)
        #expect(input == 2)
    }

    private func requireCopyable<T: Copyable>(_ value: T) {}

    private enum FirstError: Swift.Error { case rejected }
    private enum SecondError: Swift.Error { case rejected }
    private enum AppendError: Swift.Error { case rejected }

    private final class Lifetime {
        var destroyed = 0
    }

    private struct Owned: ~Copyable {
        let value: Int
    }

    private struct Cursor: ~Copyable, ~Escapable {
        let values: Span<Int>
        var index = 0

        @_lifetime(copy values)
        init(_ values: Span<Int>) { self.values = values }
    }

    private struct Reader: Parsing, ~Copyable {
        let lifetime: Lifetime
        deinit { lifetime.destroyed += 1 }

        borrowing func parse(_ input: inout Cursor) -> Owned {
            let value = input.values[input.index]
            input.index += 1
            return Owned(value: value)
        }
    }

    private func discard<T: ~Copyable>(_ value: consuming T) {}
}

#endif
