//
//  GameDatabase.swift
//  NerdleKit
//
//  Created by Andrii Zinoviev on 29.09.2024.
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
        static let date = Column("date")
    }
    
    public var id: GameID?
    public var date: Date
    public var state: GameState
    public var termination: GameTermination
    
    mutating func didInsert(_ inserted: InsertionSuccess) {
        self.id = GameID(rawValue: inserted.rowID)
    }
}

public struct GameHistoryItem: Identifiable {
    public let id: GameID
    public let date: Date
    public let state: GameState
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
    public func logGame(state: GameState, date: Date) throws -> GameID {
        guard let termination = state.termination else {
            throw Error.notFinished
        }
        
        var row = GameHistoryItemRow(
            date: date,
            state: state,
            termination: termination
        )
        
        try row.save(self.db)
        
        return try row.id.unwrap()
    }
    
    public func allGames() throws -> [GameHistoryItem] {
        let rows = try GameHistoryItemRow
            .order(GameHistoryItemRow.Columns.date.desc)
            .fetchAll(self.db)
        
        return try rows.map {
            GameHistoryItem(
                id: try $0.id.unwrap(),
                date: $0.date,
                state: $0.state,
                termination: $0.termination
            )
        }
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
