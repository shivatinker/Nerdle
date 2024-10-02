//
//  GameDatabase.swift
//  NerdleKit
//

import Foundation
import GRDB

public struct GameID: Codable, Hashable, RawRepresentable, DatabaseValueConvertible, ExpressibleByIntegerLiteral {
    public let rawValue: Int64
    
    public init(rawValue: Int64) {
        self.rawValue = rawValue
    }
    
    public init(integerLiteral value: IntegerLiteralType) {
        self.rawValue = Int64(value)
    }
}

private struct GameHistoryItemRow: Codable, FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "game_history"
    
    enum Columns {
        static let date = Column(CodingKeys.date)
        static let dailyGameDate = Column(CodingKeys.dailyGameDate)
    }
    
    public var id: GameID?
    public var date: Date
    public var state: GameState
    public var termination: GameTermination
    public var dailyGameDate: Day?
    
    mutating func didInsert(_ inserted: InsertionSuccess) {
        self.id = GameID(rawValue: inserted.rowID)
    }
}

public enum GameMode: Codable, Equatable, DatabaseValueConvertible {
    case daily(Day)
    case practice
}

public struct GameHistoryItem: Identifiable {
    public let id: GameID
    public let date: Date
    public let state: GameState
    public let mode: GameMode
    public let termination: GameTermination
}

public struct HistoryStats {
    public let gamesPlayed: Int
    public let gamesWon: Int
    
    public init(gamesPlayed: Int, gamesWon: Int) {
        self.gamesPlayed = gamesPlayed
        self.gamesWon = gamesWon
    }
}

public struct GameDatabase {
    enum Error: Swift.Error {
        case notFinished
    }
    
    private let db: Database
    
    init(_ db: Database) {
        self.db = db
    }
    
    @discardableResult
    public func logGame(state: GameState, date: Date, mode: GameMode = .practice) throws -> GameID {
        guard let termination = state.termination else {
            throw Error.notFinished
        }
        
        var row = GameHistoryItemRow(
            date: date,
            state: state,
            termination: termination,
            dailyGameDate: self.dailyGameDate(mode: mode)
        )
        
        try row.save(self.db)
        
        return try row.id.unwrap()
    }
    
    public func allGames() throws -> [GameHistoryItem] {
        let rows = try GameHistoryItemRow
            .order(GameHistoryItemRow.Columns.date.desc)
            .fetchAll(self.db)
        
        return try rows.map(self.historyItem)
    }
    
    private func dailyGameDate(mode: GameMode) -> Day? {
        switch mode {
        case let .daily(day):
            return day
        case .practice:
            return nil
        }
    }
    
    private func gameMode(day: Day?) -> GameMode {
        if let day {
            return .daily(day)
        }
        else {
            return .practice
        }
    }
    
    public func game(day: Day) throws -> GameHistoryItem? {
        try GameHistoryItemRow
            .filter(GameHistoryItemRow.Columns.dailyGameDate == day)
            .fetchOne(self.db)
            .map(self.historyItem)
    }
    
    public func game(id: GameID) throws -> GameHistoryItem {
        try GameHistoryItemRow.fetchOne(self.db, key: id)
            .map(self.historyItem)
            .unwrap()
    }
    
    private func historyItem(_ row: GameHistoryItemRow) throws -> GameHistoryItem {
        GameHistoryItem(
            id: try row.id.unwrap(),
            date: row.date,
            state: row.state,
            mode: self.gameMode(day: row.dailyGameDate),
            termination: row.termination
        )
    }
    
    public func stats() throws -> HistoryStats {
        let request = SQLRequest<Row>(sql: """
        SELECT 
        COUNT(*) AS total,
        COUNT(CASE WHEN termination = 'won' THEN 1 END) AS won
        FROM \(GameHistoryItemRow.databaseTableName)
        """)
                                      
        let row = try request.fetchOne(self.db).unwrap()
        
        return HistoryStats(
            gamesPlayed: row["total"],
            gamesWon: row["won"]
        )
    }
}
