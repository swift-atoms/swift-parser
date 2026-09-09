#if Predicate
import Predicate
import Parser
import Iterator
import Either
import Testing

@Suite struct PredicateIterationParserTests {
    private enum Fault: Error, Equatable { case source }
    private struct Input: Iterating {
        var elements: ArraySlice<Int>
        var fails = false
        mutating func next() throws(Fault) -> Int? {
            if fails { throw .source }
            return elements.popFirst()
        }
    }

    @Test func rejectionConsumesExactlyOneElement() throws {
        var input = Input(elements: [1, 2, 3])
        let parser = Predicate<Int> { $0.isMultiple(of: 2) }.parser(for: Input.self)
        do {
            _ = try parser.parse(&input)
            Issue.record("Expected rejection")
        } catch {
            guard case .left(.rejected) = error else {
                Issue.record("Unexpected error: \(error)")
                return
            }
        }
        #expect(try parser.parse(&input) == 2)
        #expect(input.elements == [3])
    }

    @Test func sourceFailureAndExhaustionRemainDistinct() {
        let parser = Predicate<Int>.always.parser(for: Input.self)
        var empty = Input(elements: [])
        do {
            _ = try parser.parse(&empty)
            Issue.record("Expected exhaustion")
        } catch {
            guard case .left(.empty) = error else {
                Issue.record("Unexpected error: \(error)")
                return
            }
        }
        var failed = Input(elements: [], fails: true)
        do {
            _ = try parser.parse(&failed)
            Issue.record("Expected source failure")
        } catch {
            guard case .right(.source) = error else {
                Issue.record("Unexpected error: \(error)")
                return
            }
        }
    }

    private struct Token: ~Copyable { let value: Int }
    private struct Tokens: Iterating, ~Copyable {
        var value = 0
        mutating func next() -> Token? {
            value += 1
            return Token(value: value)
        }
    }
    @Test func noncopyableOutputIsTransferred() throws {
        var input = Tokens()
        let parser = Predicate<Token> { $0.value == 1 }.parser(for: Tokens.self)
        let token = try parser.parse(&input)
        #expect(token.value == 1)
    }
}

private struct Loan: ~Copyable, ~Escapable {
    let values: Span<Int>
    @_lifetime(copy values)
    init(_ values: Span<Int>) { self.values = values }
}
private struct Loans: Iterating, ~Copyable, ~Escapable {
    let values: Span<Int>
    var offset = 0
    @_lifetime(copy values)
    init(_ values: Span<Int>) { self.values = values }
    @_lifetime(&self)
    mutating func next() -> Loan? {
        guard offset < values.count else { return nil }
        defer { offset += 1 }
        return Loan(values.extracting(offset..<(offset + 1)))
    }
}
extension PredicateIterationParserTests {
    @Test func scopedOutputRemainsBorrowedFromInput() throws {
        let values = [42]
        var input = Loans(values.span)
        let parser = Predicate<Loan> { $0.values[0] == 42 }.parser(for: Loans.self)
        let output = try parser.parse(&input)
        #expect(output.values[0] == 42)
    }
}

#endif
