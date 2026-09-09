import Parser
import Testing

/// Call-site examples using small copyable parsers.
/// These illustrate syntax; ownership behavior is covered separately.
@Suite
struct MappingCallSiteExamples {
    @Test
    func mapInline() {
        let parser = Number().map { $0 * 2 }

        var input = 21
        #expect(parser.parse(&input) == 42)
    }

    @Test
    func storeAndReuseMap() {
        let map = Number().map

        let doubled = map { $0 * 2 }
        let text = map { "Number: \($0)" }

        var input = 21
        #expect(doubled.parse(&input) == 42)
        #expect(text.parse(&input) == "Number: 21")
    }

    @Test
    func flatMapInline() throws {
        let parser = Number().flatMap { amount in
            Advance(by: amount)
        }

        var input = 21
        #expect(try parser.parse(&input) == 42)
        #expect(input == 42)
    }

    @Test
    func storeFlatMap() throws {
        let flatMap = Number().flatMap
        let parser = flatMap { Advance(by: $0) }

        var input = 21
        #expect(try parser.parse(&input) == 42)
    }

    @Test
    func mapFailureThroughTheProperty() {
        let parser = NonnegativeNumber().map.failure { _ in
            DisplayError.invalidNumber
        }

        var input = -1
        #expect(throws: DisplayError.invalidNumber) {
            try parser.parse(&input)
        }
    }

    @Test
    func storeMapThenMapItsFailure() {
        let map = NonnegativeNumber().map
        let parser = map.failure { _ in DisplayError.invalidNumber }

        var input = -1
        #expect(throws: DisplayError.invalidNumber) {
            try parser.parse(&input)
        }
    }

    @Test
    func throwingMapThenFailureMap() {
        let parser = Number()
            .map { (number: consuming Int) throws(NumberError) -> Int in
                guard number >= 0 else { throw .negative }
                return number * 2
            }
            .map.failure { _ in DisplayError.invalidNumber }

        var input = -1
        #expect(throws: DisplayError.invalidNumber) {
            try parser.parse(&input)
        }
    }

    @Test
    func chainTheProperties() throws {
        let parser = Number()
            .map { $0 * 2 }
            .flatMap { Advance(by: $0) }
            .map { "Result: \($0)" }

        var input = 14
        #expect(try parser.parse(&input) == "Result: 42")
        #expect(input == 42)
    }
}

// Minimal parsers keep the examples focused on the mapping call sites.
private struct Number: Parsing {
    func parse(_ input: inout Int) -> Int { input }
}

private struct Advance: Parsing {
    let by: Int

    func parse(_ input: inout Int) -> Int {
        input += by
        return input
    }
}

private struct NonnegativeNumber: Parsing {
    func parse(_ input: inout Int) throws(NumberError) -> Int {
        guard input >= 0 else { throw .negative }
        return input
    }
}

private enum NumberError: Error { case negative }
private enum DisplayError: Error { case invalidNumber }
