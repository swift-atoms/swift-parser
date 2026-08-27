import Either
public import Text

public protocol _EitherChain {
    associatedtype _Left
    associatedtype _Right
    var _left: _Left? { get }
    var _right: _Right? { get }
}

extension Either: _EitherChain {

    @inlinable
    public var _left: Left? { left }

    @inlinable
    public var _right: Right? { right }
}

extension Either {

    @inlinable
    public var first: Left? { left }
}

extension Either where Right: _EitherChain {

    @inlinable
    public var second: Right._Left? { right?._left }
}

extension Either where Right: _EitherChain, Right._Right: _EitherChain {

    @inlinable
    public var third: Right._Right._Left? { right?._right?._left }
}

extension Either
where
    Right: _EitherChain,
    Right._Right: _EitherChain,
    Right._Right._Right: _EitherChain
{

    @inlinable
    public var fourth: Right._Right._Right._Left? { right?._right?._right?._left }
}

extension Either
where
    Right: _EitherChain,
    Right._Right: _EitherChain,
    Right._Right._Right: _EitherChain,
    Right._Right._Right._Right: _EitherChain
{

    @inlinable
    public var fifth: Right._Right._Right._Right._Left? { right?._right?._right?._right?._left }
}

extension Either
where
    Right: _EitherChain,
    Right._Right: _EitherChain,
    Right._Right._Right: _EitherChain,
    Right._Right._Right._Right: _EitherChain,
    Right._Right._Right._Right._Right: _EitherChain
{

    @inlinable
    public var sixth: Right._Right._Right._Right._Right._Left? {
        right?._right?._right?._right?._right?._left
    }
}

extension Either: Parser.Error.Located.`Protocol`
where Left: Parser.Error.Located.`Protocol`, Right: Parser.Error.Located.`Protocol` {

    @inlinable
    public var offset: Text.Position {
        switch self {
        case .left(let e): return e.offset
        case .right(let e): return e.offset
        }
    }
}

extension Either
where Left: Parser.Error.Located.`Protocol`, Right: Parser.Error.Located.`Protocol` {

    @inlinable
    public var earliestOffset: Text.Position {
        offset
    }
}
