public import Parser

extension Parser.Error {

    public struct Map<Upstream: Parser.`Protocol`, NewFailure: Swift.Error>: Parser.`Protocol`
    where
        Upstream.Input: ~Copyable & ~Escapable,
        Upstream.Output: ~Copyable & ~Escapable
    {
        public typealias Input = Upstream.Input

        public typealias Output = Upstream.Output

        public typealias Failure = NewFailure

        public let upstream: Upstream

        public let transform: (Upstream.Failure) -> NewFailure

        @inlinable
        package init(
            _ upstream: Upstream,
            transform: @escaping (Upstream.Failure) -> NewFailure
        ) {
            self.upstream = upstream
            self.transform = transform
        }

        @inlinable
        @_lifetime(borrow self, &input)
        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            do throws(Upstream.Failure) {
                return try upstream.parse(&input)
            } catch {
                throw transform(error)
            }
        }
    }
}

extension Parser.Error.Transform
where
    Upstream.Input: ~Copyable & ~Escapable,
    Upstream.Output: ~Copyable & ~Escapable
{

    @inlinable
    public func map<NewFailure: Swift.Error>(
        _ transform: @escaping (Upstream.Failure) -> NewFailure
    ) -> Parser.Error.Map<Upstream, NewFailure> {
        Parser.Error.Map(upstream, transform: transform)
    }
}
