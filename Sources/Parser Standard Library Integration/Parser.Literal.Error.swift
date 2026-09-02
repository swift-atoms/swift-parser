public import Parser

extension Parser.Literal {

    public enum Error: Swift.Error, Equatable {

        case mismatch(expected: String, found: String)
    }
}
