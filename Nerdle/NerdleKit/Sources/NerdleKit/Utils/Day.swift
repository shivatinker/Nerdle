//
//  Day.swift
//  NerdleKit
//
//  Created by Andrii Zinoviev on 02.10.2024.
//

import Foundation
import GRDB

public struct Day: Codable, Equatable, CustomStringConvertible {
    enum Error: Swift.Error {
        case invalidDayFormat
    }
    
    public let year: Int
    public let month: Int
    public let day: Int
    
    public init(date: Date) {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        
        self.year = components.year!
        self.month = components.month!
        self.day = components.day!
    }
    
    init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }
    
    public init(string: String) throws {
        let components = string.split(separator: "-")
        
        guard components.count == 3 else {
            throw Error.invalidDayFormat
        }
        
        guard let year = Int(components[0]),
              let month = Int(components[1]),
              let day = Int(components[2])
        else {
            throw Error.invalidDayFormat
        }
        
        self.day = day
        self.month = month
        self.year = year
    }
    
    var string: String {
        "\(self.year)-\(self.month)-\(self.day)"
    }
    
    public var description: String {
        let date = Calendar.current.date(from: DateComponents(year: self.year, month: self.month, day: self.day))!
        return date.formatted(date: .long, time: .omitted)
    }
}

extension Day: DatabaseValueConvertible {
    public var databaseValue: DatabaseValue {
        self.string.databaseValue
    }
    
    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> Day? {
        guard let string = String.fromDatabaseValue(dbValue) else {
            return nil
        }
        
        return try? self.init(string: string)
    }
}
