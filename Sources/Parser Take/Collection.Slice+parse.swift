public import Collection
public import Input

extension Collection.Slice.`Protocol` where Self: Input.Input.Streaming {

    @inlinable
    public mutating func parse<Body: Parser.`Protocol`>(
        @Parser.Take.Builder<Self> _ build: () -> Body
    ) throws(Body.Failure) -> Body.Output where Body.Input == Self {
        try build().parse(&self)
    }

    @inlinable
    public func parsing<Body: Parser.`Protocol`>(
        @Parser.Take.Builder<Self> _ build: () -> Body
    ) throws(Body.Failure) -> Body.Output where Body.Input == Self {
        var copy = self
        return try build().parse(&copy)
    }
}
