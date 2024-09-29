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
