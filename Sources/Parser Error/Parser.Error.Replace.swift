extension Parser.Error {

    public struct Replace<Upstream: Parser.`Protocol`>
    where
        Upstream.Input: ~Copyable & ~Escapable,
        Upstream.Output: Copyable & Escapable
    {
        @usableFromInline
        let upstream: Upstream

        @usableFromInline
        let output: Upstream.Output

        @inlinable
        package init(_ upstream: Upstream, output: Upstream.Output) {
            self.upstream = upstream
            self.output = output
        }
    }
}

extension Parser.Error.Replace: Parser.`Protocol`
where
    Upstream.Input: ~Copyable & ~Escapable,
    Upstream.Output: Copyable & Escapable
{

    public typealias Input = Upstream.Input

    public typealias Output = Upstream.Output

    public typealias Failure = Never

    @inlinable
    public func parse(_ input: inout Input) -> Output {
        do throws(Upstream.Failure) {
            return try upstream.parse(&input)
        } catch {
            return output
        }
    }
}

extension Parser.Error.Transform
where
    Upstream.Input: ~Copyable & ~Escapable,
    Upstream.Output: Copyable & Escapable
{

    @inlinable
    public func replace(with output: Upstream.Output) -> Parser.Error.Replace<Upstream> {
        Parser.Error.Replace(upstream, output: output)
    }
}
