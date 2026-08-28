extension Parser.Filter {

    public enum Error: Swift.Error, Sendable, Equatable {

        case validationFailed(value: String, reason: String)
    }
}
