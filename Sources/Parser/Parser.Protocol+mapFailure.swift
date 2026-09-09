extension Parser.`Protocol`
where Self: ~Copyable, Input: ~Copyable & ~Escapable, Output: ~Copyable & ~Escapable {
    /// Convenience spelling for `map.failure`.
    @inlinable
    public consuming func mapFailure<NewFailure: Swift.Error>(
        _ transform: @escaping (Failure) -> NewFailure
    ) -> Parser::Map<Self>.Error.Parser<NewFailure> {
        self.map.failure(transform)
    }
}
