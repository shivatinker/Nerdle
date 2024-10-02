//
//  ExpressionValidatorTests.swift
//  NerdleKit
//

@testable import NerdleKit
import XCTest

final class ExpressionValidatorTests: XCTestCase {
    func testValidator() throws {
        try self.check("1+3=4")
        try self.check("42-32=10")
        try self.check("1*2+3*4=14")
        try self.check("0+0*0=0")
        try self.check("222/2+5=116")
        try self.check("10/5=2")
    }
    
    func testCompletion() throws {
        try self.checkCompletion("1+3=", 4)
        try self.checkCompletion("111*324/2+54=", 18036)
        self.checkCompletionError("10-20=")
    }
    
    func testErrors() throws {
        self.checkError("1+3=5")
        self.checkError("2/0=4")
        self.checkError("11111*11111=0")
        self.checkError("1+2=")
        self.checkError("5/4=1")
        self.checkError("4/8=0")
        self.checkError("10-20=10")
    }
    
    private func check(
        _ string: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let tokens = try ExpressionLexer().tokens(string: string)
        let topLevel = try ExpressionParser.parse(tokens)
        try ExpressionValidator.validate(topLevel)
    }
    
    private func checkError(
        _ string: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(try self.check(string, file: file, line: line))
    }
    
    private func checkCompletion(
        _ string: String,
        _ expected: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let tokens = try ExpressionLexer().tokens(string: string)
        let topLevel = try ExpressionParser.parse(tokens)
        let result = try ExpressionValidator.complete(topLevel)
        XCTAssertEqual(result, expected, file: file, line: line)
    }
    
    private func checkCompletionError(
        _ string: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(try {
            let tokens = try ExpressionLexer().tokens(string: string)
            let topLevel = try ExpressionParser.parse(tokens)
            _ = try ExpressionValidator.complete(topLevel)
        }(), file: file, line: line)
    }
}
