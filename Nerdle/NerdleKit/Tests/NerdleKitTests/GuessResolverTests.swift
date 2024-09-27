//
//  GuessResolverTests.swift
//  NerdleKit
//
//  Created by Andrii Zinoviev on 26.09.2024.
//

@testable import NerdleKit
import XCTest

final class GuessResolverTests: XCTestCase {
    func testResolver() throws {
        try self.check(
            "21+32=53",
            "10-8+5=7",
            "WXXXWWWX"
        )
        
        try self.check(
            "11+44=55",
            "11+44=55",
            "CCCCCCCC"
        )
        
        try self.check(
            "11+44=55",
            "1+1+8=10",
            "CWWXXCXX"
        )
        
        try self.check(
            "11111111*0=0",
            "12131415*0=0",
            "CXCXCXCXCCCC"
        )
        
        try self.check(
            "1+2=3",
            "2+1=3",
            "WCWCC"
        )
    }
    
    private func check(
        _ target: String,
        _ guess: String,
        _ expected: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let targetEquation = try Equation(string: target)
        let guessEquation = try Equation(string: guess)
        let resolver = GuessResolver(target: targetEquation)
        let result = resolver.resolve(guessEquation)
        XCTAssertEqual(result.states.description, expected, file: file, line: line)
    }
}
