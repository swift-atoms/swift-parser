public import Collection_Primitives

extension Collection.Slice.`Protocol` {

    public var remainingCount: Int {
        var count = 0
        var i = startIndex
        while i < endIndex {
            i = index(after: i)
            count += 1
        }
        return count
    }
}
