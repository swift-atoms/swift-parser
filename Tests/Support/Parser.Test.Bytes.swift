public import Collection
import Iterable
public import Parser

extension Parser.Test {

    public struct Bytes: Collection.`Protocol`, Sendable {
        public let storage: [UInt8]

        public init(_ bytes: [UInt8]) {
            self.storage = bytes
        }
    }
}

extension Parser.Test.Bytes {
    public typealias Index = Index.Index<UInt8>

    public var startIndex: Index { .zero }

    public var endIndex: Index {
        Index.Count(Cardinal(UInt(storage.count))).map(Ordinal.init)
    }

    public subscript(position: Index) -> UInt8 {
        storage[Int(bitPattern: position)]
    }

    public func index(after i: Index) -> Index {

        try! i.successor.exact()
    }

    public borrowing func makeIterator() -> Parser.Test.Iterator {
        Parser.Test.Iterator(storage)
    }
}
