extension Parser.`Protocol` where Self: ~Copyable {

    @inlinable
    public consuming func map<NewOutput: ~Copyable & Escapable>(
        _ transform: @escaping (consuming Output) -> NewOutput
    ) -> Parser.Map<Self, NewOutput, Failure> {
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
        _ transform: @escaping
            (consuming Output) throws(TransformFailure) -> NewOutput
    ) -> Parser.Map<
        Self,
        NewOutput,
        Either<Failure, TransformFailure>
    > {
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

extension Parser.`Protocol` where Self: ~Copyable, Failure == Never {

    @inlinable
    public consuming func map<
        NewOutput: ~Copyable & Escapable,
        TransformFailure: Swift.Error
    >(
        _ transform: @escaping
            (consuming Output) throws(TransformFailure) -> NewOutput
    ) -> Parser.Map<Self, NewOutput, TransformFailure> {
        .init(
            upstream: self,
            transform: transform,
            failure: { $0 }
        )
    }
}
