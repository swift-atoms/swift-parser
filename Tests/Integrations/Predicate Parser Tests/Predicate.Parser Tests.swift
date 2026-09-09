#if Predicate
import Parser
import Predicate
import Testing

@Suite
struct `Predicate.Parser Tests` {
    @Test
    func `a predicate consumes exactly one matching element`() throws {
        var input: Substring = "123x"
        let result = try Parser { Predicate<Character> { $0.isNumber } }.parse(&input)
        #expect(result == "1")
        #expect(input == "23x")
    }

    @Test
    func `rejection leaves input intact`() {
        var input: Substring = "x123"
        #expect(throws: Predicate<Character>.Parser<Substring>.Error.rejected) {
            _ = try Digit().parse(&input)
        }
        #expect(input == "x123")
    }

    @Test
    func `empty input has a distinct failure`() {
        var input: Substring = ""
        #expect(throws: Predicate<Character>.Parser<Substring>.Error.empty) {
            _ = try Digit().parse(&input)
        }
    }
}

private struct Digit: Parsing {
    typealias Failure = Predicate<Character>.Parser<Substring>.Error
    var body: some Parsing<Substring, Character, Failure> {
        Predicate<Character> { $0.isNumber }
    }
}

#endif
