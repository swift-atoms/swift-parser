import Parser
import Parser_Test_Support
import Testing

@Suite
struct `Parser supports function and builder construction` {
    @Test
    func `copies retain the same noncopyable implementation until the last copy is released`() {
        let count = Count()
        do {
            let copy: Parser<Int, Value, Never>
            do {
                let parser = Parser { Owner(count: count) }
                copy = parser
                var input = 0
                let output = parser.parse(&input)
                #expect(output.value == 1)
            }
            #expect(count.destroyed == 0)
            var input = 10
            let output = copy.parse(&input)
            #expect(output.value == 11)
        }
        #expect(count.destroyed == 1)
    }

    @Test
    func `builder infers channels and runs once`() {
        let count = Count()
        let parser = Parser {
            count.build()
        }
        requireParsing(parser)
        var input = 3
        #expect(parser.parse(&input) == 3)
        #expect(parser.parse(&input) == 4)
        #expect(input == 5)
        #expect(count.builds == 1)
    }

    @Test
    func `explicit channels accept a builder and preserve typed failure`() {
        let parser = Parser<Int, Int, Rejected> {
            Parser<Int, Int, Rejected> { input throws(Rejected) in
                input += 1
                throw .invalid
            }
        }
        var input = 0
        do throws(Rejected) {
            _ = try parser.parse(&input)
            Issue.record("Expected rejection")
        } catch {
            #expect(error == .invalid)
        }
        #expect(input == 1)
    }

    @Test
    func `builder retains a noncopyable owner and produces noncopyable outputs`() {
        let count = Count()
        do {
            let parser = Parser { Owner(count: count) }
            var input = 0
            let first = parser.parse(&input)
            let second = parser.parse(&input)
            #expect(first.value == 1)
            #expect(second.value == 2)
            #expect(count.destroyed == 0)
        }
        #expect(count.destroyed == 1)
    }

    @Test
    func `direct construction produces noncopyable outputs`() {
        let parser = Parser<Int, Value, Never> { Value(value: $0) }
        var input = 42
        let result = parser.parse(&input)
        #expect(result.value == 42)
    }
}

private func requireParsing<P: Parsing>(_ parser: P)
where P.Input == Int, P.Output == Int, P.Failure == Never {}

private enum Rejected: Error { case invalid }
private struct Value: ~Copyable { let value: Int }
private final class Count {
    var builds = 0
    var destroyed = 0
    func build() -> Parser<Int, Int, Never> {
        builds += 1
        return Parser { input in
            let result = input
            input += 1
            return result
        }
    }
}
private struct Owner: Parsing, ~Copyable {
    let count: Count
    borrowing func parse(_ input: inout Int) -> Value {
        input += 1
        return Value(value: input)
    }
    deinit { count.destroyed += 1 }
}

@Suite
struct `Parser closures consume input and preserve typed failure` {

    @Test
    func `a closure parses and consumes input`() throws(any Swift.Error) {
        let parser = Parser<Substring, Character, ParseFailure> { input throws(ParseFailure) in
            guard let first = input.first else { throw .empty }
            input = input.dropFirst()
            return first
        }
        var input: Substring = "ab"
        #expect(try parser.parse(&input) == "a")
        #expect(input == "b")
    }

    @Test
    func `a nonthrowing closure needs no try`() {
        let pure = Parser<Substring, Int, Never> { input in input.count }
        var input: Substring = "abc"
        #expect(pure.parse(&input) == 3)
    }

    @Test
    func `a closure propagates its typed failure`() {
        let parser = Parser<Substring, Character, ParseFailure> { _ throws(ParseFailure) in
            throw .empty
        }
        var input: Substring = ""
        #expect(throws: ParseFailure.empty) {
            try parser.parse(&input)
        }
    }
}

private enum ParseFailure: Swift.Error, Equatable {
    case empty
}

@Suite
private struct `Parser ownership and lifetime constraints survive module emission` {

    @Test(arguments: ["Escaping Parser Input.swift"])
    func `concrete parser results cannot outlive input`(_ fixture: String) throws {
        let diagnostic = try Compiler.emissionFailure(named: fixture)
        #expect(diagnostic.contains("escapes its scope"), "\(diagnostic)")
    }

    @Test
    func `concrete parser supports scoped input and direct scoped output`() throws {
        let result = try Compiler.emitFixture(named: "Scoped Parser Construction.swift")
        #expect(result.status == 0, "\(result.diagnostic)")
    }

    @Test
    func `a parser builder cannot consume an owner captured from outside`() throws {
        let diagnostic = try Compiler.emissionFailure(named: "Captured Parser Owner.swift")
        #expect(diagnostic.contains("noncopyable 'owner' cannot be consumed when captured"))
    }

}
