#if Always
    public import Parser_Core
    public import Always

    extension Always::Always {

        @frozen
        public struct Parser<Input>: Parser::Parsing {

            public let base: Always::Always<Value>

            @inlinable
            public init(_ base: Always::Always<Value>) {
                self.base = base
            }

            @inlinable
            public init(_ value: Value) {
                self.base = Always::Always(value)
            }
        }

        @inlinable
        public func parser<Input>() -> Parser<Input> {
            .init(self)
        }
    }

    extension Always::Always.Parser {
        public typealias Output = Value

        public typealias Failure = Never
    }

    extension Always::Always.Parser {
        @inlinable
        public borrowing func parse(_ input: inout Input) -> Output {
            base.value
        }
    }

#endif
