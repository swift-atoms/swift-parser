#if Repetition
public import Repetition
public import Cardinal
public import Either
public import Checkpoint

extension Repetition
where Bounds: Cardinal.Range, Operation: Parsing & ~Copyable,
      Operation.Input: Restorable & ~Copyable & ~Escapable, Operation.Input.Checkpoint: Equatable,
      Operation.Output: Copyable & Escapable {
    public struct Parser<Rejection: Swift.Error, Fatal: Swift.Error>: Parsing, ~Copyable
    where Operation.Failure == Either<Rejection, Fatal> {
        public typealias Input = Operation.Input
        public typealias Output = [Operation.Output]
        public typealias Failure = Either<Repetition<Bounds, Operation>.Error, Fatal>
        public let wrapped: Repetition<Bounds, Operation>

        public init(_ wrapped: consuming Repetition<Bounds, Operation>) { self.wrapped = wrapped }

        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            guard wrapped.bounds.contains(wrapped.bounds.minimum) else { throw .left(.emptyBounds) }
            var output: Output = []
            var count = Cardinal.zero
            while wrapped.bounds.permitsAnother(after: count) {
                let saved = input.checkpoint
                guard count.rawValue != UInt.max else { throw .left(.countOverflow) }
                do throws(Operation.Failure) {
                    let value = try wrapped.operation.parse(&input)
                    output.append(value)
                } catch {
                    switch error {
                    case .left:
                        input.seek(to: saved)
                        guard wrapped.bounds.contains(count) else { throw .left(.insufficient(actual: count)) }
                        return output
                    case .right(let fatal):
                        throw .right(fatal)
                    }
                }
                guard input.checkpoint != saved else { input.seek(to: saved); throw .left(.noProgress) }
                count = Cardinal(count.rawValue + 1)
            }
            guard wrapped.bounds.contains(count) else { throw .left(.insufficient(actual: count)) }
            return output
        }
    }
}

extension Repetition.Parser: Copyable
where Bounds: Cardinal.Range,
      Operation: Parsing<Operation.Input, Operation.Output, Operation.Failure> & Copyable,
      Operation.Input: Restorable & ~Copyable & ~Escapable,
      Operation.Input.Checkpoint: Equatable,
      Operation.Output: Copyable & Escapable {}
#endif
