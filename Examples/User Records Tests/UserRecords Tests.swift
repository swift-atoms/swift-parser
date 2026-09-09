import Parser
import Testing

@Suite struct `User records example` {
    @Test func `a complete batch produces domain values`() throws {
        var input: Substring = "Alice,34\nBob,28\n"
        #expect(try UserRecords().parse(&input) == [User(name: "Alice", age: 34), User(name: "Bob", age: 28)])
        #expect(input.isEmpty)
    }

    @Test func `a malformed record is restored after accepted records`() throws {
        var input: Substring = "Alice,34\nBob,not-an-age\nCarol,41\n"
        #expect(try UserRecords().parse(&input) == [User(name: "Alice", age: 34)])
        #expect(input == "Bob,not-an-age\nCarol,41\n")
    }

    @Test func `a missing newline restores the entire incomplete record`() throws {
        var input: Substring = "Alice,34\nBob,28"
        #expect(try UserRecords().parse(&input) == [User(name: "Alice", age: 34)])
        #expect(input == "Bob,28")
    }

    @Test(arguments: ["131", "9999999999999999999999999999"])
    func `invalid ages propagate and preserve the following record`(age: String) {
        var input: Substring = "Alice,34\nBob,\(age)\nCarol,41\n"
        do {
            _ = try UserRecords().parse(&input)
            Issue.record("Expected invalid age")
        } catch {
            switch error {
            case .right(.age(let value)): #expect(value == age)
            default: Issue.record("Unexpected error: \(error)")
            }
        }
        #expect(input == "Carol,41\n")
    }

    @Test func `empty input is an empty batch`() throws {
        var input: Substring = ""
        #expect(try UserRecords().parse(&input).isEmpty)
    }
}
