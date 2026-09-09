import Parser
import Testing

@Suite
struct `Builder preserves the concrete parser expression` {
    @Test
    func `an explicit builder returns the original concrete operation`() {
        let parser: Count = count()
        var input: Substring = "swift"

        #expect(parser.parse(&input) == 5)
        #expect(input == "swift")
    }

    @Builder<Substring>
    private func count() -> Count {
        Count()
    }
}

private struct Count: Parsing {
    var body: some Parsing<Substring, Int, Never> {
        Parser<Substring, Int, Never> { input in
            input.count
        }
    }
}
