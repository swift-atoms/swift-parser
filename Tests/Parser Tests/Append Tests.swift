import Parser
import Testing

@Suite
struct `Append operates independently of parsing` {

    @Test
    func `tuple append changes the accumulated type`() {
        let append = Append<(Int, String), Bool, (Int, String, Bool), Never>()

        let result = append((42, "answer"), true)

        #expect(result.0 == 42)
        #expect(result.1 == "answer")
        #expect(result.2)
    }

    @Test
    func `tuple append supports empty and singleton packs`() {
        let start = Append<Void, Int, Int, Never>()
        let extend = Append<Int, String, (Int, String), Never>()

        let first = start((), 42)
        let pair = extend(first, "answer")

        #expect(pair.0 == 42)
        #expect(pair.1 == "answer")
    }

    @Test
    func `array append accepts a distinct element type`() {
        let append = Append<[Int], Int, [Int], Never> { accumulated, next in
            var result = accumulated
            result.append(next)
            return result
        }

        #expect(append([], 1) == [1])
        #expect(append([1, 2], 3) == [1, 2, 3])
    }

    @Test
    func `string append preserves operand order`() {
        let append = Append<String, String, String, Never> { $0 + $1 }

        #expect(append("hello", " world") == "hello world")
    }

    @Test
    func `a reusable witness transfers noncopyable operands and results`() {
        let append = Append<Owned, Owned, Owned, Never> {
            (accumulated: consuming Owned, next: consuming Owned) in
            Owned(value: accumulated.value + next.value)
        }

        let first = append(Owned(value: "a"), Owned(value: "b"))
        let second = append(first, Owned(value: "c"))

        #expect(second.value == "abc")
    }

    @Test
    func `bounded append preserves its concrete failure type`() throws {
        let append = Append<[Int], Int, [Int], CapacityError> {
            (accumulated, next) throws(CapacityError) in
            guard accumulated.count < 2 else { throw .full }
            return accumulated + [next]
        }

        // This assignment checks that calling the witness retains typed throws.
        let operation: ([Int], Int) throws(CapacityError) -> [Int] = {
            (accumulated, next) throws(CapacityError) in
            try append(accumulated, next)
        }

        #expect(try operation([1], 2) == [1, 2])
        #expect(throws: CapacityError.full) {
            try operation([1, 2], 3)
        }
    }

    @Test
    func `append carries both scoped operand lifetimes into its result`() {
        let append = Append<Span<Int>, Span<Int>, Joined, Never> {
            (accumulated: consuming Span<Int>, next: consuming Span<Int>) in
            Joined(accumulated, next)
        }
        let first = [1, 2]
        let second = [3, 4]
        let joined = append(first.span, second.span)

        #expect(joined.first[0] == 1)
        #expect(joined.second[1] == 4)
    }

    @Test
    func `scoped results preserve typed failures`() throws {
        let append = Append<Span<Int>, Span<Int>, Joined, CapacityError> {
            (accumulated: consuming Span<Int>, next: consuming Span<Int>) throws(CapacityError) in
            guard accumulated.count + next.count <= 3 else { throw .full }
            return Joined(accumulated, next)
        }
        let first = [1, 2]
        let second = [3]
        let joined = try append(first.span, second.span)
        #expect(joined.second[0] == 3)

        do throws(CapacityError) {
            _ = try append(first.span, first.span)
            Issue.record("Expected capacity failure")
        } catch {
            #expect(error == .full)
        }
    }

    private struct Joined: ~Copyable, ~Escapable {
        let first: Span<Int>
        let second: Span<Int>

        @_lifetime(copy first, copy second)
        init(_ first: consuming Span<Int>, _ second: consuming Span<Int>) {
            self.first = first
            self.second = second
        }
    }

    private enum CapacityError: Swift.Error {
        case full
    }

    private struct Owned: ~Copyable {
        let value: String
    }
}
