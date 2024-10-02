//
//  GuessInputStateTests.swift
//  NerdleKit
//

@testable import NerdleKit
import XCTest

final class GuessInputStateTests: XCTestCase {
    func testSimpleCase() throws {
        var state = GuessInputState(size: 5)
        self.checkState(state, "_____", 0)
        
        state.input(.digit(1))
        self.checkState(state, "1____", 1)
        
        state.input(.binop(.plus))
        self.checkState(state, "1+___", 2)
        
        state.input(.digit(2))
        self.checkState(state, "1+2__", 3, completion: "=3")
        
        state.input(.equals)
        self.checkState(state, "1+2=_", 4, completion: "3")
        
        state.input(.digit(3))
        self.checkState(state, "1+2=3", 4)
        
        XCTAssertEqual(state.submit(), try Equation(string: "1+2=3"))
        self.checkState(state, "1+2=3", 4)
    }
    
    func testOverflow() throws {
        var state = GuessInputState(size: 5)
        
        state.input(string: "1+2=3")
        self.checkState(state, "1+2=3", 4)
        
        state.input(.digit(4))
        self.checkState(state, "1+2=4", 4, hasError: true)
    }
    
    func testErase() throws {
        var state = GuessInputState(size: 5)
        
        state.input(string: "1+2=4")
        self.checkState(state, "1+2=4", 4, hasError: true)
        
        state.eraseBackwards()
        self.checkState(state, "1+2=_", 4, completion: "3")
        
        state.eraseBackwards()
        self.checkState(state, "1+2__", 3, completion: "=3")
        
        state.eraseBackwards()
        self.checkState(state, "1+___", 2)
        
        state.eraseBackwards()
        self.checkState(state, "1____", 1)
        
        state.eraseBackwards()
        self.checkState(state, "_____", 0)
        
        state.eraseBackwards()
        self.checkState(state, "_____", 0)
    }
    
    func testCursorPositionChange() throws {
        var state = GuessInputState(size: 5)
        
        state.input(string: "1+2=4")
        self.checkState(state, "1+2=4", 4, hasError: true)
        
        state.setCursorPosition(to: 2)
        self.checkState(state, "1+2=4", 2, hasError: true)
        
        state.input(.digit(3))
        self.checkState(state, "1+3=4", 3)
        
        state.eraseBackwards()
        self.checkState(state, "1+3_4", 3)
        
        state.setCursorPosition(to: 1)
        self.checkState(state, "1+3_4", 1)
        
        state.input(.binop(.divide))
        self.checkState(state, "1/3_4", 2)
        
        state.moveCursorBackward()
        self.checkState(state, "1/3_4", 1)
    }
    
    func testSpace() throws {
        var state = GuessInputState(size: 5)
        
        state.input(.digit(1))
        self.checkState(state, "1____", 1)
        
        state.inputSpace()
        self.checkState(state, "1____", 2)
        
        state.input(.digit(3))
        self.checkState(state, "1_3__", 3)
        
        state.input(.digit(4))
        state.input(.digit(5))
        self.checkState(state, "1_345", 4)
        
        state.inputSpace()
        self.checkState(state, "1_34_", 4)
    }
    
    func testCompletion() throws {
        var state = GuessInputState(size: 8)
        
        state.input(string: "14+52")
        self.checkState(state, "14+52___", 5, completion: "=66")
        
        state.input(.equals)
        self.checkState(state, "14+52=__", 6, completion: "66")
        
        XCTAssertEqual(state.submit(), nil)
        self.checkState(state, "14+52=66", 7)
        
        XCTAssertEqual(state.submit(), try Equation(string: "14+52=66"))
        self.checkState(state, "14+52=66", 7)
    }
    
    func testSubstituteLastGuess() throws {
        var state = GuessInputState(size: 8)
        
        state.input(string: "14+52")
        self.checkState(state, "14+52___", 5, completion: "=66")
        
        state.substituteLastGuess(try Equation(string: "11+22=33"))
        self.checkState(state, "11+22___", 5, completion: "=33")
        
        state.setCursorPosition(to: 0)
        state.input(.digit(3))
        self.checkState(state, "31+22___", 1, completion: "=53")
    }
    
    func testClear() throws {
        var state = GuessInputState(size: 8)
        
        state.input(string: "14+52")
        self.checkState(state, "14+52___", 5, completion: "=66")
        
        state.clear()
        self.checkState(state, "________", 5)
    }
    
    // MARK: Utils
    
    private func checkState(
        _ state: GuessInputState,
        _ expected: String,
        _ cursorPosition: Int,
        completion: String? = nil,
        hasError: Bool = false,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(state.description, expected, file: file, line: line)
        XCTAssertEqual(state.cursorPosition, cursorPosition, file: file, line: line)
        XCTAssertEqual(state.error != nil, hasError, file: file, line: line)
        XCTAssertEqual(state.completion?.map(\.description).joined(), completion, file: file, line: line)
    }
}
