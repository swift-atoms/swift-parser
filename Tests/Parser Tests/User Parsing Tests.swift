import Parser
import Testing

@Suite
struct `User parsing from Substring` {
    @Test
    func `a builder parses a name and age into a user`() throws {
        let parser = Parser {
            User.Parser()
        }
        var input: Substring = "Alice,42"

        let user = try parser.parse(&input)

        #expect(user == User(name: "Alice", age: 42))
        #expect(input.isEmpty)
    }

    @Test
    func `parsing a user preserves the remaining input`() throws {
        var input: Substring = "Alice,42;Bob,35"

        let user = try User.Parser().parse(&input)

        #expect(user == User(name: "Alice", age: 42))
        #expect(input == ";Bob,35")
    }

    @Test(arguments: ["", ",42", "Alice", "Alice,", "Alice,-1", "Alice,abc"])
    func `an invalid record fails without consuming input`(_ text: String) {
        var input = text[...]

        #expect(throws: User.Parser.Failure.invalidRecord) {
            try User.Parser().parse(&input)
        }
        #expect(input == text[...])
    }
}

private struct User: Equatable {
    let name: String
    let age: Int
}

extension User {

    struct Parser: Parsing {
        enum Failure: Swift.Error {
            case invalidRecord
        }

        var body: some Parsing<Substring, User, Failure> {
            Parser::Parser<Substring, User, Failure> { input throws(Failure) in
                let name = input.prefix { $0 != "," }
                guard !name.isEmpty, name.endIndex != input.endIndex else {
                    throw .invalidRecord
                }

                let remainder = input[name.endIndex...].dropFirst()
                let digits = remainder.prefix { $0 >= "0" && $0 <= "9" }
                guard let age = Int(digits) else {
                    throw .invalidRecord
                }

                input = remainder[digits.endIndex...]
                return User(name: String(name), age: age)
            }
        }
    }
}
