//
//  GameStateTests.swift
//  NerdleKit
//

@testable import NerdleKit
import XCTest

final class GameStateTests: XCTestCase {
    private let configuration = GameConfiguration(
        size: 8,
        maxGuesses: 3
    )
    
    func testWonTermination() throws {
        var state = GameState(
            target: try Equation(string: "12+23=35"),
            configuration: self.configuration
        )
        
        XCTAssertEqual(state.termination, nil)
        
        state.addGuess(equation: try Equation(string: "15+62=77"))
        XCTAssertEqual(state.termination, nil)
        
        state.addGuess(equation: try Equation(string: "12+33=45"))
        XCTAssertEqual(state.termination, nil)
        
        state.addGuess(equation: try Equation(string: "12+23=35"))
        XCTAssertEqual(state.termination, .won)
    }
    
    func testLostTermination() throws {
        var state = GameState(
            target: try Equation(string: "12+23=35"),
            configuration: self.configuration
        )
        
        XCTAssertEqual(state.termination, nil)
        
        state.addGuess(equation: try Equation(string: "15+62=77"))
        XCTAssertEqual(state.termination, nil)
        
        state.addGuess(equation: try Equation(string: "12+33=45"))
        XCTAssertEqual(state.termination, nil)
        
        state.addGuess(equation: try Equation(string: "12+24=36"))
        XCTAssertEqual(state.termination, .lost)
    }
    
    func testExport() throws {
        var state = GameState(
            target: try Equation(string: "12+23=35"),
            configuration: self.configuration
        )
        
        state.addGuess(equation: try Equation(string: "15+62=77"))
        state.addGuess(equation: try Equation(string: "12+33=45"))
        state.addGuess(equation: try Equation(string: "12+23=35"))
        
        XCTAssertEqual(try state.export(), """
        Nerdle [12+23=35]: won
        🟩🟨🟩⬛🟨🟩⬛⬛
        🟩🟩🟩🟨🟩🟩⬛🟩
        🟩🟩🟩🟩🟩🟩🟩🟩
        """)
    }
    
    func testEncoding() throws {
        var state = GameState(
            target: try Equation(string: "12+23=35"),
            configuration: self.configuration
        )
        
        state.addGuess(equation: try Equation(string: "15+62=77"))
        state.addGuess(equation: try Equation(string: "12+33=45"))
        state.addGuess(equation: try Equation(string: "12+23=35"))
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(state)
        
        let string = try XCTUnwrap(String(data: data, encoding: .utf8))
        print(String(data: data, encoding: .utf8)!)
        
        XCTAssertEqual(string, """
        {
          "configuration" : {
            "maxGuesses" : 3,
            "size" : 8
          },
          "guesses" : [
            {
              "equation" : "15+62=77",
              "states" : "CWCXWCXX"
            },
            {
              "equation" : "12+33=45",
              "states" : "CCCWCCXC"
            },
            {
              "equation" : "12+23=35",
              "states" : "CCCCCCCC"
            }
          ],
          "target" : "12+23=35"
        }
        """)
        
        let decoder = JSONDecoder()
        let decodedState = try decoder.decode(GameState.self, from: data)
        XCTAssertEqual(decodedState, state)
    }
}
