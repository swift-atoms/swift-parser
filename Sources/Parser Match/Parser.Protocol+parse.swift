public import Collection

extension Parser.`Protocol` {

    @inlinable
    public func parse(
        _ input: consuming Input
    ) throws(Either<Failure, Parser.Match.Error>) -> Output
    where Input: Collection.Slice.`Protocol` & Copyable {
        var input = input
        let output: Output
        do throws(Failure) {
            output = try parse(&input)
        } catch {
            throw .left(error)
        }
        guard input.isEmpty else {
            throw .right(.expectedEnd(remaining: input.remainingCount))
        }
        return output
    }
}

extension Parser.`Protocol` where Failure == Parser.Match.Error {

    @inlinable
    public func parse(_ input: consuming Input) throws(Parser.Match.Error) -> Output
    where Input: Collection.Slice.`Protocol` & Copyable {
        var input = input
        let output = try parse(&input)
        guard input.isEmpty else {
            throw .expectedEnd(remaining: input.remainingCount)
        }
        return output
    }
}
