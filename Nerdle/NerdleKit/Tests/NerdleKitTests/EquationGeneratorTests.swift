//
//  EquationGeneratorTests.swift
//  NerdleKit
//
//  Created by Andrii Zinoviev on 26.09.2024.
//

@testable import NerdleKit
import XCTest

final class EquationGeneratorTests: XCTestCase {
    func testSanity() {
        self.check(size: 5)
        self.check(size: 8)
        self.check(size: 15)
    }
    
    func testDailyEquation() {
        let date = Date(timeIntervalSince1970: 1727879909)
        let day = Day(date: date)
        let equation = EquationGenerator.generateDailyEquation(day: day, size: 8)
        XCTAssertEqual(equation.description, "47*7=329")
    }
    
    private func check(size: Int) {
        let count = 100
        var generator = EquationGenerator(seed: 42)
        let equations = generator.generateEquations(size: size, count: count)
        
        print(equations.map(\.description).joined(separator: "\n"))
        XCTAssertEqual(equations.count, count)
    }
}
