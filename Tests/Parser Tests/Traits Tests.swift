#if Append && Skip && Map && Repetition && Collection
import Parser
import Testing

@Suite
struct `Parser traits compose through one import` {
    @Test
    func `prefix recognition sequencing punctuation and mapping compose`() throws {
        let parser = Parser {
            Repetition((Cardinal(1)...), operation: Predicate<Character> { $0 != "," }).parser(for: Substring.self)
            ","
            Repetition((Cardinal(1)...), operation: Predicate<Character> { $0 >= "0" && $0 <= "9" }).parser(for: Substring.self)
        }
        .map { (name: Substring, age: Substring) in
            (name: String(name), age: Int(age))
        }

        var input: Substring = "Alice,42;next"
        let result = try parser.parse(&input)

        #expect(result.name == "Alice")
        #expect(result.age == 42)
        #expect(input == ";next")
    }
}
#endif
