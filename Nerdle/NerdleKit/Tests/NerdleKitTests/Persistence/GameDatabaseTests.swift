//
//  GameDatabaseTests.swift
//  NerdleKit
//
//  Created by Andrii Zinoviev on 29.09.2024.
//

@testable import NerdleKit
import XCTest

final class GameDatabaseTests: XCTestCase {
    func testHistoryLogging() throws {
        let controller = try DatabaseController(path: nil)
        
        try controller.write { db in
            try db.logGame(state: self.makeWonGame(), date: Date(timeIntervalSince1970: 1727610396))
            try db.logGame(state: self.makeLostGame(), date: Date(timeIntervalSince1970: 1727610440))
        }
        
        let games = try controller.read { db in
            try db.allGames()
        }
        
        XCTAssertEqual(games.count, 2)
        
        XCTAssertEqual(games[safe: 0]?.id, 2)
        XCTAssertEqual(games[safe: 0]?.termination, .lost)
        
        XCTAssertEqual(games[safe: 1]?.id, 1)
        XCTAssertEqual(games[safe: 1]?.termination, .won)
    }
    
    func testDailyGameLogging() throws {
        let controller = try DatabaseController(path: nil)
        
        try controller.write { db in
            try db.logGame(
                state: self.makeWonGame(),
                date: Date(timeIntervalSince1970: 1727610396),
                mode: .practice
            )
            
            try db.logGame(
                state: self.makeLostGame(),
                date: Date(timeIntervalSince1970: 1727610440),
                mode: .daily(try Day(string: "2024-9-27"))
            )
        }
        
        let games = try controller.read { db in
            try db.allGames()
        }
        
        XCTAssertEqual(games.count, 2)
        XCTAssertEqual(games[safe: 0]?.mode, .daily(try Day(string: "2024-9-27")))
        XCTAssertEqual(games[safe: 1]?.mode, .practice)
        
        try controller.read { db in
            XCTAssertNotNil(try db.gameState(day: try Day(string: "2024-9-27")))
            XCTAssertNil(try db.gameState(day: try Day(string: "2024-9-28")))
        }
    }

    func testStats() throws {
        let controller = try DatabaseController(path: nil)
        
        try controller.write { db in
            try db.logGame(state: self.makeWonGame(), date: Date(timeIntervalSince1970: 1727610396))
            try db.logGame(state: self.makeWonGame(), date: Date(timeIntervalSince1970: 1727610360))
            try db.logGame(state: self.makeLostGame(), date: Date(timeIntervalSince1970: 1727610440))
        }
        
        let stats = try controller.read { db in
            try db.stats()
        }
        
        XCTAssertEqual(stats.gamesPlayed, 3)
        XCTAssertEqual(stats.gamesWon, 2)
    }
    
    // MARK: Utils
    
    private func makeWonGame() throws -> GameState {
        var state = try self.makeTestGame()
        
        state.addGuess(equation: try Equation(string: "1+3=4"))
        state.addGuess(equation: try Equation(string: "1+2=3"))
        
        XCTAssertEqual(state.termination, .won)
        
        return state
    }
    
    private func makeLostGame() throws -> GameState {
        var state = try self.makeTestGame()
        
        state.addGuess(equation: try Equation(string: "1+3=4"))
        state.addGuess(equation: try Equation(string: "1+5=6"))
        
        XCTAssertEqual(state.termination, .lost)
        
        return state
    }
    
    private func makeTestGame() throws -> GameState {
        GameState(
            target: try Equation(string: "1+2=3"),
            configuration: GameConfiguration(size: 5, maxGuesses: 2)
        )
    }
}
