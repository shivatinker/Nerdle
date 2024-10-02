//
//  DayTests.swift
//  NerdleKit
//

@testable import NerdleKit
import XCTest

final class DayTests: XCTestCase {
    func testStringConversion() throws {
        let day = Day(year: 2024, month: 9, day: 27)
        let string = day.string
        XCTAssertEqual(string, "2024-9-27")
        let decodedDay = try Day(string: string)
        XCTAssertEqual(day, decodedDay)
    }
}
