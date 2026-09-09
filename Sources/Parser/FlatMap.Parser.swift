public import Either

extension FlatMap
where Source: Parsing & ~Copyable,
    Source.Input: ~Copyable & ~Escapable,
    Source.Output: ~Copyable & ~Escapable {
    /// Selects and executes a continuation on the remaining input.
    public struct Parser<Continuation: Parsing & ~Copyable>: Parsing, ~Copyable
    where Continuation.Input == Source.Input,
        Continuation.Input: ~Copyable & ~Escapable,
        Continuation.Output: ~Copyable & Escapable {
        public typealias Input = Source.Input
        public typealias Output = Continuation.Output
        public typealias Failure = Either<Source.Failure, Continuation.Failure>

        public let base: FlatMap<Source.Output>.Transform<Continuation>
        public let upstream: Source

        @inlinable
        public init(
            _ base: FlatMap<Source.Output>.Transform<Continuation>,
            upstream: consuming Source
        ) {
            self.base = base
            self.upstream = upstream
        }

        @inlinable
        public init(
            upstream: consuming Source,
            transform: @escaping (consuming Source.Output) -> Continuation
        ) {
            self.init(.init(transform), upstream: upstream)
        }

        @inlinable
        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            let value: Source.Output
            do throws(Source.Failure) {
                value = try upstream.parse(&input)
            } catch {
                throw .left(error)
            }
            let downstream = base(value)
            do throws(Continuation.Failure) {
                return try downstream.parse(&input)
            } catch {
                throw .right(error)
            }
        }
    }

    @inlinable
    public consuming func callAsFunction<P: Parsing & ~Copyable>(
        _ transform: @escaping (consuming Source.Output) -> P
    ) -> Parser<P>
    where P.Input == Source.Input, P.Input: ~Copyable & ~Escapable,
        P.Output: ~Copyable & Escapable {
        .init(upstream: source, transform: transform)
    }
}

extension FlatMap.Parser: Copyable
where Source: Parsing<Source.Input, Source.Output, Source.Failure> & Copyable,
    Source.Input: ~Copyable & ~Escapable,
    Source.Output: ~Copyable & ~Escapable,
    Continuation: Parsing<Continuation.Input, Continuation.Output, Continuation.Failure> & ~Copyable,
    Continuation.Input: ~Copyable & ~Escapable,
    Continuation.Output: ~Copyable & Escapable {}
