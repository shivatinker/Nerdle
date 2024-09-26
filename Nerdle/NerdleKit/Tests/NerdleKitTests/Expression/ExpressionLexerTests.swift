//
//  ExpressionLexerTests.swift
//  NerdleKit
//
//  Created by Andrii Zinoviev on 26.09.2024.
//

@testable import NerdleKit
import XCTest

final class ExpressionLexerTests: XCTestCase {
    func testLexer() throws {
        try self.check("12*42+1=41", [
            .number(12),
            .binop(.multiply),
            .number(42),
            .binop(.plus),
            .number(1),
            .equals,
            .number(41),
            .eof,
        ])
    }
    
    func testLeadingZeroes() throws {
        try self.check("003/004-010=047", [
            .number(3),
            .binop(.divide),
            .number(4),
            .binop(.minus),
            .number(10),
            .equals,
            .number(47),
            .eof,
        ])
    }
    
    func testInvalidCharacter() {
        XCTAssertThrowsError(
            try ExpressionLexer().tokens(string: "12+r=54$")
        )
    }
    
    private func check(
        _ string: String,
        _ expectedTokens: [ExpressionToken],
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let tokens = try ExpressionLexer().tokens(string: string)
        
        XCTAssertEqual(tokens, expectedTokens, file: file, line: line)
    }
}
