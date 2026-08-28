extension Parser.Witness: Parser.`Protocol` where Input: ~Copyable & ~Escapable {

    public typealias Body = Never

    @inlinable
    public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
        try _parse(&input)
    }
}
