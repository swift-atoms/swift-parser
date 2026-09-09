public import Either

extension Map
where Source: Parsing & ~Copyable,
    Source.Input: ~Copyable & ~Escapable,
    Source.Output: ~Copyable & ~Escapable {
    @inlinable
    public consuming func callAsFunction<NewOutput: ~Copyable>(
        _ transform: @escaping (consuming Source.Output) -> NewOutput
    ) -> Parser<NewOutput, Source.Failure> {
        .init(upstream: source, transform: transform, failure: { $0 })
    }

    @inlinable
    public consuming func callAsFunction<NewOutput: ~Copyable, TransformFailure: Swift.Error>(
        _ transform: @escaping (consuming Source.Output) throws(TransformFailure) -> NewOutput
    ) -> Parser<NewOutput, Either<Source.Failure, TransformFailure>> {
        .init(
            upstream: source,
            transform: { value throws(Either<Source.Failure, TransformFailure>) in
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

extension Map
where Source: Parsing & ~Copyable,
    Source.Input: ~Copyable & ~Escapable,
    Source.Output: ~Copyable & ~Escapable,
    Source.Failure == Never {
    @inlinable
    public consuming func callAsFunction<NewOutput: ~Copyable>(
        _ transform: @escaping (consuming Source.Output) -> NewOutput
    ) -> Parser<NewOutput, Never> {
        .init(upstream: source, transform: transform, failure: { $0 })
    }

    @inlinable
    public consuming func callAsFunction<NewOutput: ~Copyable, TransformFailure: Swift.Error>(
        _ transform: @escaping (consuming Source.Output) throws(TransformFailure) -> NewOutput
    ) -> Parser<NewOutput, TransformFailure> {
        .init(upstream: source, transform: transform, failure: { $0 })
    }
}
