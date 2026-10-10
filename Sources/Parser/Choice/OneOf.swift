#if Choice
public import Parser_Core
public import Checkpoint

public enum OneOf {}

extension OneOf {
    public struct Two<P0: Parsing, P1: Parsing>: Parsing
    where P0.Input == P1.Input, P0.Output == P1.Output,
          P0.Input: Restorable & ~Copyable & ~Escapable,
          P1.Input: ~Copyable & ~Escapable,
          P0.Output: ~Copyable & Escapable, P1.Output: ~Copyable & Escapable {

        public typealias Input = P0.Input
        public typealias Output = P0.Output
        public typealias Failure = Error
        public enum Error: Swift.Error {
            case first(P0.Failure)
            case second(P1.Failure)
            case rejected(first: P0.Failure, second: P1.Failure)
        }
        public let p0: P0
        public let p1: P1
        public let rejectFirst: (P0.Failure) -> Bool
        public let rejectSecond: (P1.Failure) -> Bool
        public let serializationRejectFirst: (P0.Failure) -> Bool
        public let serializationRejectSecond: (P1.Failure) -> Bool

        public init(_ p0: P0, _ p1: P1,
                    rejectFirst: @escaping (P0.Failure) -> Bool,
                    rejectSecond: @escaping (P1.Failure) -> Bool,
                    serializationRejectFirst: ((P0.Failure) -> Bool)? = nil,
                    serializationRejectSecond: ((P1.Failure) -> Bool)? = nil) {
            self.p0 = p0; self.p1 = p1
            self.rejectFirst = rejectFirst; self.rejectSecond = rejectSecond
            self.serializationRejectFirst = serializationRejectFirst ?? rejectFirst
            self.serializationRejectSecond = serializationRejectSecond ?? rejectSecond
        }

        public borrowing func parse(_ input: inout Input) throws(Error) -> Output {
            let saved = input.checkpoint
            let first: P0.Failure
            do throws(P0.Failure) { return try p0.parse(&input) } catch {
                guard rejectFirst(error) else { throw .first(error) }
                first = error
                input.seek(to: saved)
            }
            do throws(P1.Failure) { return try p1.parse(&input) } catch {
                guard rejectSecond(error) else { throw .second(error) }
                input.seek(to: saved)
                throw .rejected(first: first, second: error)
            }
        }
    }
}
#endif
