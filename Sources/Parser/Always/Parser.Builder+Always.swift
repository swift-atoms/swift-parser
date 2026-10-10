#if Always
public import Parser_Core
public import Always

extension Parser::Builder {

    @inlinable
    public static func buildBlock() -> Always::Always<Void>.Parser<Input> {
        Always::Always(()).parser()
    }
}

#endif
