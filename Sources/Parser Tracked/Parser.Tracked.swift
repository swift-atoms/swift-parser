public import Input

extension Parser {

    public struct Tracked<Base: Input.Input.`Protocol`> {

        @usableFromInline
        internal var base: Base

        @usableFromInline
        internal var offset: Index<Element>

        @inlinable
        public init(_ base: Base) {
            self.base = base
            self.offset = .zero
        }

        @inlinable
        public init(_ base: Base, offset: Index<Element>) {
            self.base = base
            self.offset = offset
        }
    }
}

extension Parser.Tracked {

    @inlinable
    public var input: Base { base }

    @inlinable
    public var currentOffset: Index<Element> { offset }
}

extension Parser.Tracked: Input.Input.`Protocol` {

    public typealias Element = Base.Element

    public struct Checkpoint: Comparable {
        @usableFromInline
        let baseCheckpoint: Base.Checkpoint

        @usableFromInline
        let trackedOffset: Index<Element>

        @inlinable
        package init(baseCheckpoint: Base.Checkpoint, trackedOffset: Index<Element>) {
            self.baseCheckpoint = baseCheckpoint
            self.trackedOffset = trackedOffset
        }
    }

    @inlinable
    public var isEmpty: Bool {
        base.isEmpty
    }

    @inlinable
    public var count: Index<Element>.Count {
        base.count
    }

    @inlinable
    public var checkpoint: Checkpoint {
        Checkpoint(baseCheckpoint: base.checkpoint, trackedOffset: offset)
    }

    @inlinable
    public var bounds: ClosedRange<Checkpoint> {
        let baseRange = base.bounds
        return Checkpoint(
            baseCheckpoint: baseRange.lowerBound,
            trackedOffset: .zero
        )...Checkpoint(baseCheckpoint: baseRange.upperBound, trackedOffset: .zero)
    }

    @inlinable
    public mutating func seek(to checkpoint: Checkpoint) {
        base.seek(to: checkpoint.baseCheckpoint)
        offset = checkpoint.trackedOffset
    }

    @inlinable
    @discardableResult
    public mutating func advance() throws(Input.Stream.Error) -> Element {
        offset += .one
        return try base.advance()
    }

    @inlinable
    public mutating func advance(by count: Index<Element>.Count) {
        offset += count
        base.advance(by: count)
    }
}

extension Parser.Tracked.Checkpoint {

    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.baseCheckpoint == rhs.baseCheckpoint
    }

    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.baseCheckpoint < rhs.baseCheckpoint
    }
}

extension Parser.Tracked.Checkpoint: Sendable where Base.Checkpoint: Sendable {}

extension Parser.Tracked {

    @inlinable
    public mutating func parseTracked<P: Parser.`Protocol`>(
        _ parser: P
    ) throws(Parser.Error.Located<P.Failure>) -> (output: P.Output, start: Index<Element>)
    where P.Input == Base {
        let start = currentOffset
        let countBefore = base.count
        let value: P.Output
        do throws(P.Failure) {
            value = try parser.parse(&base)
        } catch {
            throw Parser.Error.Located(error, at: start)
        }
        offset += countBefore.subtract.saturating(base.count)
        return (value, start)
    }
}

extension Parser.Tracked {

    @inlinable
    public func savepoint() -> (base: Base, offset: Index<Element>) {
        (base, offset)
    }

    @inlinable
    public mutating func restore(to savepoint: (base: Base, offset: Index<Element>)) {
        self.base = savepoint.base
        self.offset = savepoint.offset
    }
}
