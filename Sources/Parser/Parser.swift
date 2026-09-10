#if Map
public import Either
#endif

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

    @inlinable
    public init<P: Parsing & ~Copyable>(
        @Builder<Input> _ build: () -> P
    )
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

#if Map
extension Parser
where Input: ~Copyable & ~Escapable, Output: ~Copyable & Escapable {

    @inlinable
    public init<P: Parsing & ~Copyable>(
        _ transform: @escaping (consuming P.Output) -> Output,
        @Builder<Input> _ build: () -> P
    ) where P.Input: ~Copyable & ~Escapable,
            P.Output: ~Copyable & ~Escapable,
            P.Input == Input, P.Failure == Failure {
        self.init { build().map(transform) }
    }

    @inlinable
    @_disfavoredOverload
    public init<P: Parsing & ~Copyable, TransformFailure: Swift.Error>(
        _ transform: @escaping (consuming P.Output) throws(TransformFailure) -> Output,
        @Builder<Input> _ build: () -> P
    ) where P.Input: ~Copyable & ~Escapable,
            P.Output: ~Copyable & ~Escapable,
            P.Input == Input, Failure == Either<P.Failure, TransformFailure> {
        self.init { build().map(transform) }
    }

    @inlinable
    public init<P: Parsing & ~Copyable>(
        _ transform: @escaping (consuming P.Output) throws(Failure) -> Output,
        @Builder<Input> _ build: () -> P
    ) where P.Input: ~Copyable & ~Escapable,
            P.Output: ~Copyable & ~Escapable,
            P.Input == Input, P.Failure == Never {
        self.init { build().map(transform) }
    }
}

extension Parser
where Input: ~Copyable & ~Escapable, Output: ~Copyable & Escapable, Failure == Never {

    @inlinable
    public init<P: Parsing & ~Copyable>(
        _ transform: @escaping (consuming P.Output) -> Output,
        @Builder<Input> _ build: () -> P
    ) where P.Input: ~Copyable & ~Escapable,
            P.Output: ~Copyable & ~Escapable,
            P.Input == Input, P.Failure == Never {
        self.init { build().map(transform) }
    }
}

#endif
