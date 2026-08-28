extension Parser.Builder {

    @inlinable
    public static func buildBlock() -> Parser.Always<Input, Void> {
        Parser.Always(())
    }
}
