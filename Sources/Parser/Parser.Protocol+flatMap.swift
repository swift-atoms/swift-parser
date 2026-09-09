extension Parser.`Protocol`
where Self: ~Copyable, Input: ~Copyable & ~Escapable, Output: ~Copyable & ~Escapable {
    /// Binds this parser so the transformation can be supplied now or later.
    /// Experimental: see README.md for the Swift 6.4 destruction limitation.
    @_owned
    @inlinable
    public var flatMap: Parser::FlatMap<Self> {
        consuming get { .init(consume self) }
    }
}
