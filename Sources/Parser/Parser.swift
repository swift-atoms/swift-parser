/// A parser represented by a typed parsing function.
public struct Parser<
    Input: ~Copyable & ~Escapable,
    Output: ~Copyable & ~Escapable,
    Failure: Swift.Error
>: Parsing {
    public var _parse: @_lifetime(&input) (_ input: inout Input) throws(Failure) -> Output

    @inlinable
    public init(_ parse: @escaping @_lifetime(&input) (_ input: inout Input) throws(Failure) -> Output) {
        self._parse = parse
    }

    @inlinable
    @_lifetime(borrow self, &input)
    public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
        try _parse(&input)
    }
}

extension Parser
where Input: ~Copyable & ~Escapable, Output: ~Copyable & Escapable {
    /// Builds once and retains the composition in a parsing closure.
    ///
    /// Scoped outputs remain supported by direct construction and concrete
    /// Parsing implementations; this initializer requires an escapable output.
    @inlinable
    public init<P: Parsing & ~Copyable>(@Builder<Input> _ build: () -> P)
    where
        P.Input: ~Copyable & ~Escapable,
        P.Output: ~Copyable & Escapable,
        P.Input == Input, P.Output == Output, P.Failure == Failure
    {
        let composition = build()
        self._parse = { input throws(Failure) in
            try composition.parse(&input)
        }
    }
}
