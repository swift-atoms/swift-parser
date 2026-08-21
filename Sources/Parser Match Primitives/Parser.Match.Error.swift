extension Parser.Match {

    public enum Error: Swift.Error, Sendable, Equatable {

        case literalMismatch(expected: String, found: String)

        case predicateFailed(description: String)

        case byteMismatch(expected: [UInt8], found: [UInt8])

        case expectedEnd(remaining: Int)
    }
}
