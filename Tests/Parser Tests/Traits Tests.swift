#if Append && Skip && Map && Prefix
import Parser
import Testing

@Suite
struct `Parser traits compose through one import` {
    @Test
    func `prefix recognition sequencing punctuation and mapping compose`() throws {
        let parser = Parser {
            Prefix.While<Character>.Parser<Substring>(
                .init(minimum: 1) { $0 != "," }
            )
            ","
            Prefix.While<Character>(minimum: 1) { $0 >= "0" && $0 <= "9" }
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
