public import Input

extension Parser {

    public struct Tracked<Base: __ParserInput.`Protocol`> {

        @usableFromInline
        internal var base: Base

        @usableFromInline
        internal var offset: Int

        @inlinable
        public init(_ base: Base) {
            self.base = base
            self.offset = 0
        }

        @inlinable
        public init(_ base: Base, offset: Int) {
            self.base = base
            self.offset = offset
        }
    }
}

extension Parser.Tracked {

    @inlinable
    public var input: Base { base }

    @inlinable
    public var currentOffset: Int { offset }
}

extension Parser.Tracked: __ParserInput.`Protocol` {

    public typealias Element = Base.Element

    public struct Checkpoint: Comparable {
        @usableFromInline
        let baseCheckpoint: Base.Checkpoint

        @usableFromInline
        let trackedOffset: Int

        @inlinable
        package init(baseCheckpoint: Base.Checkpoint, trackedOffset: Int) {
            self.baseCheckpoint = baseCheckpoint
            self.trackedOffset = trackedOffset
        }
    }

    @inlinable
    public var isEmpty: Bool {
        base.isEmpty
    }

    @inlinable
    public var count: Int {
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
            trackedOffset: 0
        )...Checkpoint(baseCheckpoint: baseRange.upperBound, trackedOffset: 0)
    }

    @inlinable
    public mutating func seek(to checkpoint: Checkpoint) {
        base.seek(to: checkpoint.baseCheckpoint)
        offset = checkpoint.trackedOffset
    }

    @inlinable
    @discardableResult
    public mutating func advance() throws(Input.Stream.Error) -> Element {
        let element = try base.advance()
        offset += 1
        return element
    }

    @inlinable
    public mutating func advance(by count: Int) {
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
    ) throws(Parser.Error.Located<P.Failure>) -> (output: P.Output, start: Int)
    where P.Input == Base {
        let start = currentOffset
        let countBefore = base.count
        let value: P.Output
        do throws(P.Failure) {
            value = try parser.parse(&base)
        } catch {
            throw Parser.Error.Located(error, at: start)
        }
        offset += countBefore - base.count
        return (value, start)
    }
}

extension Parser.Tracked {

    @inlinable
    public func savepoint() -> (base: Base, offset: Int) {
        (base, offset)
    }

    @inlinable
    public mutating func restore(to savepoint: (base: Base, offset: Int)) {
        self.base = savepoint.base
        self.offset = savepoint.offset
    }
}
