public import Either

extension Parsing
where
Self: ~Copyable,
Input: ~Copyable & ~Escapable,
Output: ~Copyable & ~Escapable
{

    @inlinable
    public consuming func map<
        NewOutput: ~Copyable & Escapable
    >(
        _ transform: @escaping (consuming Output) -> NewOutput
    ) -> Parser::Map<Output, NewOutput, Failure>.Parser<Self> {
        .init(
            upstream: self,
            transform: transform,
            failure: { $0 }
        )
    }

    @inlinable
    public consuming func map<
        NewOutput: ~Copyable & Escapable,
        TransformFailure: Swift.Error
    >(
        _ transform: @escaping (consuming Output) throws(TransformFailure) -> NewOutput
    ) -> Parser::Map<Output, NewOutput, Either<Failure, TransformFailure>>.Parser<Self> {
        .init(
            upstream: self,
            transform: { value throws(Either<Failure, TransformFailure>) in
                do throws(TransformFailure) {
                    return try transform(value)
                } catch {
                    throw .right(error)
                }
            },
            failure: { .left($0) }
        )
    }
}

extension Parsing
where
Self: ~Copyable,
Input: ~Copyable & ~Escapable,
Output: ~Copyable & ~Escapable,
Failure == Never
{

    @inlinable
    public consuming func map<
        NewOutput: ~Copyable & Escapable,
        TransformFailure: Swift.Error
    >(
        _ transform: @escaping
        (consuming Output) throws(TransformFailure) -> NewOutput
    ) -> Parser::Map<Output, NewOutput, TransformFailure>.Parser<Self> {
        .init(
            upstream: self,
            transform: transform,
            failure: { $0 }
        )
    }
}
