import Parser
import Parser_Standard_Library_Integration
import Parser_Take
import Testing

@Suite
struct `Parser Standard Library Integration` {

    @Test
    func `String parses a matching prefix`() throws(any Swift.Error) {
        var input: Substring = "swift-parser"

        try "swift".parse(&input)

        #expect(input == "-parser")
    }

    @Test
    func `Array parses matching elements`() throws(any Swift.Error) {
        var input: ArraySlice = [1, 2, 3][...]

        try [1, 2].parse(&input)

        #expect(Array(input) == [3])
    }

    @Test
    func `Optional Parser parses a present parser`() throws(any Swift.Error) {
        let parser = Swift.Optional<String>.Parser("swift")
        var input: Substring = "swift-parser"

        let output: Void? = try parser.parse(&input)

        #expect(output != nil)
        #expect(input == "-parser")
    }

    @Test
    func `Optional Parser skips an absent parser`() throws(any Swift.Error) {
        let parser = Swift.Optional<String>.Parser(nil)
        var input: Substring = "swift-parser"

        let output: Void? = try parser.parse(&input)

        #expect(output == nil)
        #expect(input == "swift-parser")
    }

    @Test
    func `Parser builder uses Swift Optional Parser for buildIf`() throws(any Swift.Error) {
        let includePrefix = true
        let parser = Parser.Take.Sequence {
            if includePrefix {
                "swift"
            }
        }
        var input: Substring = "swift-parser"

        let output: Void? = try parser.parse(&input)

        #expect(output != nil)
        #expect(input == "-parser")
    }
}
