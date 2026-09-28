#if CollectionLeaves
public import Either


public import Collection



    public enum CollectionInput {}


extension Parser::CollectionInput {

    public enum Error: Swift.Error, Equatable {
        case expectedEnd(remaining: Int)
    }
}

extension Parsing {

    public func parse(
        _ input: consuming Input
    ) throws(Either<Failure, Parser::CollectionInput.Error>) -> Output
    where Input: Collection.Slice.`Protocol` & Copyable, Output: Escapable {
        var input = input
        let output: Output
        do throws(Failure) {
            output = try parse(&input)
        } catch {
            throw .left(error)
        }
        guard input.isEmpty else {
            throw .right(.expectedEnd(remaining: input.parserRemainingCount))
        }
        return output
    }
}

extension Parsing where Failure == Parser::CollectionInput.Error {

    public func parse(_ input: consuming Input) throws(Parser::CollectionInput.Error) -> Output
    where Input: Collection.Slice.`Protocol` & Copyable, Output: Escapable {
        var input = input
        let output = try parse(&input)
        guard input.isEmpty else {
            throw .expectedEnd(remaining: input.parserRemainingCount)
        }
        return output
    }
}
#endif
