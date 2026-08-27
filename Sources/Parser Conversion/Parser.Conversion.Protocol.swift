extension Parser.Conversion {

    public protocol `Protocol`<Input, Output> {

        associatedtype Input

        associatedtype Output

        associatedtype Failure: Swift.Error = Never

        func apply(_ input: Input) throws(Failure) -> Output

        func unapply(_ output: Output) throws(Failure) -> Input
    }
}
