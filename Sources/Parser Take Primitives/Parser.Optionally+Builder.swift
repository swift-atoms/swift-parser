extension Parser.Optionally {
    /// Creates an optional parser from the given result-builder closure.
    @inlinable
    public init(@Parser.Take.Builder<Wrapped.Input> _ wrapped: () -> Wrapped) {
        self.init(wrapped())
    }
}
