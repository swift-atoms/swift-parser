extension Parser {

    public struct Trace<Upstream: Parser.`Protocol`> {
        @usableFromInline
        let upstream: Upstream

        @usableFromInline
        let label: String

        @usableFromInline
        let log: (String) -> Void

        @inlinable
        public init(
            _ upstream: Upstream,
            label: String,
            log: @escaping (String) -> Void = { print($0) }
        ) {
            self.upstream = upstream
            self.label = label
            self.log = log
        }
    }
}

extension Parser.Trace: Parser.`Protocol` {

    public typealias Input = Upstream.Input

    public typealias Output = Upstream.Output

    public typealias Failure = Upstream.Failure

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        log("[\(label)] enter")
        do throws(Upstream.Failure) {
            let result = try upstream.parse(&input)
            log("[\(label)] success: \(result)")
            return result
        } catch {
            log("[\(label)] failure: \(error)")
            throw error
        }
    }
}

extension Parser.`Protocol` {

    @inlinable
    public func trace(
        _ label: String,
        log: @escaping (String) -> Void = { print($0) }
    ) -> Parser.Trace<Self> {
        Parser.Trace(self, label: label, log: log)
    }
}
