extension Parser.Conversion {

    public enum Error: Swift.Error, Sendable, Equatable {

        case unrepresentable

        case mismatch

        case absentCase
    }
}
