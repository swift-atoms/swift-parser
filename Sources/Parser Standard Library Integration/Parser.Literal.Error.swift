public import Parser

extension Parser.Literal {

    public enum Error: Swift.Error, Sendable, Equatable {

        case mismatch(expected: String, found: String)
    }
}
