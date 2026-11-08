#if CollectionLeaves
    import Collection
    import Parser
    import Collection_Parser_Test_Support
    import Testing

    enum `Parser.Rest Tests` {}

    extension `Parser.Rest Tests` {
        @Suite
        struct `Parser::Rest` {
            @Suite struct Unit {}
            @Suite struct `Edge Case` {}
        }
    }

    extension `Parser.Rest Tests`.`Parser::Rest`.Unit {
        @Test
        func `consumes all remaining input`() {
            let parser = Parser::Rest<CollectionParserTest.Input>()
            var input: CollectionParserTest.Input = [0x01, 0x02, 0x03]

            let result = parser.parse(&input)

            #expect(result == [0x01, 0x02, 0x03])
            #expect(input.isEmpty)
        }
    }

    extension `Parser.Rest Tests`.`Parser::Rest`.`Edge Case` {
        @Test
        func `returns empty slice on empty input`() {
            let parser = Parser::Rest<CollectionParserTest.Input>()
            var input: CollectionParserTest.Input = []

            let result = parser.parse(&input)

            #expect(result.isEmpty)
            #expect(input.isEmpty)
        }

        @Test
        func `returns single element`() {
            let parser = Parser::Rest<CollectionParserTest.Input>()
            var input: CollectionParserTest.Input = [0xFF]

            let result = parser.parse(&input)

            #expect(result == [0xFF])
        }
    }
#endif
