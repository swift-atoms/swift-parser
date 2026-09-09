extension Map
where Source: Parsing & ~Copyable,
    Source.Input: ~Copyable & ~Escapable,
    Source.Output: ~Copyable & ~Escapable {
    public enum Error {
        /// Changes only failure; successful values retain their lifetimes.
        public struct Parser<NewFailure: Swift.Error>: Parsing, ~Copyable {
            public typealias Input = Source.Input
            public typealias Output = Source.Output
            public typealias Failure = NewFailure

            public let base: Map<Source.Failure>.Transform<NewFailure, Never>
            public let upstream: Source

            @inlinable
            public init(
                _ base: Map<Source.Failure>.Transform<NewFailure, Never>,
                _ upstream: consuming Source
            ) {
                self.base = base
                self.upstream = upstream
            }

            @inlinable
            @_lifetime(borrow self, &input)
            public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
                do throws(Source.Failure) {
                    return try upstream.parse(&input)
                } catch {
                    throw base(error)
                }
            }
        }
    }

    @inlinable
    public consuming func failure<NewFailure: Swift.Error>(
        _ transform: @escaping (Source.Failure) -> NewFailure
    ) -> Error.Parser<NewFailure> {
        .init(.init(transform), source)
    }
}

extension Map.Error.Parser: Copyable
where Source: Parsing<Source.Input, Source.Output, Source.Failure> & Copyable,
    Source.Input: ~Copyable & ~Escapable,
    Source.Output: ~Copyable & ~Escapable {}

extension Map.Transform where Source: Swift.Error, Target: Swift.Error, Failure == Never {
    @inlinable
    public func errorParser<P: Parsing & ~Copyable>(_ upstream: consuming P) -> Map<P>.Error.Parser<Target>
    where P.Input: ~Copyable & ~Escapable, P.Output: ~Copyable & ~Escapable,
        P.Failure == Source {
        .init(self, upstream)
    }
}
