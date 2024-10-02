//
//  ExpressionParserTests.swift
//  NerdleKit
//

@testable import NerdleKit
import XCTest

final class ExpressionParserTests: XCTestCase {
    func testParser() throws {
        try self.check(
            "1+2*43-6=32",
            ExpressionParser.TopLevel(
                lhs: ExpressionParser.Expression(
                    terms: ExpressionParser.BinopList<ExpressionParser.Term>(
                        head: ExpressionParser.Term(
                            factors: ExpressionParser.BinopList<Int>(
                                head: 1
                            )
                        ),
                        tail: [
                            ExpressionParser.BinopPart<ExpressionParser.Term>(
                                value: ExpressionParser.Term(
                                    factors: ExpressionParser.BinopList<Int>(
                                        head: 2,
                                        tail: [
                                            ExpressionParser.BinopPart<Int>(
                                                value: 43,
                                                binop: .multiply
                                            ),
                                        ]
                                    )
                                ),
                                binop: .plus
                            ),
                            ExpressionParser.BinopPart<ExpressionParser.Term>(
                                value: ExpressionParser.Term(
                                    factors: ExpressionParser.BinopList<Int>(
                                        head: 6
                                    )
                                ),
                                binop: .minus
                            ),
                        ]
                    )
                ),
                rhs: 32
            )
        )
    }
    
    func testPartialInput() throws {
        try self.check(
            "1+2=",
            ExpressionParser.TopLevel(
                lhs: ExpressionParser.Expression(
                    terms: ExpressionParser.BinopList<ExpressionParser.Term>(
                        head: ExpressionParser.Term(
                            factors: ExpressionParser.BinopList<Int>(
                                head: 1
                            )
                        ),
                        tail: [
                            ExpressionParser.BinopPart<ExpressionParser.Term>(
                                value: ExpressionParser.Term(
                                    factors: ExpressionParser.BinopList<Int>(
                                        head: 2
                                    )
                                ),
                                binop: .plus
                            ),
                        ]
                    )
                ),
                rhs: nil
            )
        )
    }
    
    func testErrors() {
        self.checkError("+42-13=442")
        self.checkError("1++2=4")
        self.checkError("1+2=4-")
        self.checkError("=30-")
        self.checkError("1234")
        self.checkError("12=34=32")
        self.checkError("12=33+41")
        self.checkError("111=111")
    }
    
    private func check(
        _ expression: String,
        _ expected: ExpressionParser.TopLevel,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let tokens = try ExpressionLexer().tokens(string: expression)
        let result = try ExpressionParser.parse(tokens)
        
        XCTAssertEqual(result, expected, file: file, line: line)
    }
    
    private func checkError(
        _ expression: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(try {
            let tokens = try ExpressionLexer().tokens(string: expression)
            _ = try ExpressionParser.parse(tokens)
        }(), file: file, line: line)
    }
}
