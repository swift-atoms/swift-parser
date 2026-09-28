#if CollectionLeaves
public import Collection

extension Collection.Slice.`Protocol` {

    @usableFromInline
    package var parserRemainingCount: Int {
        var count = 0
        var index = startIndex
        while index < endIndex {
            formIndex(after: &index)
            count += 1
        }
        return count
    }
}
#endif
