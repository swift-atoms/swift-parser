extension Parser.Many {

    public enum Error: Swift.Error, Sendable, Equatable {

        case countTooLow(expected: Int, got: Int)

        case countTooHigh(expected: Int, got: Int)
    }
}
