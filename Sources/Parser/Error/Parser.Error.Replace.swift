extension Parser.Error {

    public struct Replace<Upstream: Parser.`Protocol`> {
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

extension Parser.Error.Replace: Parser.`Protocol` {

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

extension Parser.Error.Transform {

    @inlinable
    public func replace(with output: Upstream.Output) -> Parser.Error.Replace<Upstream> {
        Parser.Error.Replace(upstream, output: output)
    }
}
