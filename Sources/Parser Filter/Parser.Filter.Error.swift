extension Parser.Filter
where
    Upstream.Input: ~Copyable & ~Escapable,
    Upstream.Output: Copyable & Escapable
{

    public enum Error: Swift.Error, Sendable, Equatable {

        case validationFailed(value: String, reason: String)
    }
}
