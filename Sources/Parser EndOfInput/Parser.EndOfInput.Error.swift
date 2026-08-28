extension Parser.EndOfInput {

    public enum Error: Swift.Error, Sendable, Equatable {

        case unexpected(expected: String)
    }
}
