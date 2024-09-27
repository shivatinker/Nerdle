//
//  GameViewModel.swift
//  Nerdle
//
//  Created by Andrii Zinoviev on 27.09.2024.
//

import AppKit
import Combine
import NerdleKit

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var gameState: GameState
    @Published private(set) var inputState: GuessInputState
    
    var isInputEnabled: Bool {
        self.gameState.termination == nil
    }
    
    init(target: Equation, configuration: GameConfiguration) {
        self.gameState = GameState(target: target, configuration: configuration)
        self.inputState = GuessInputState(size: configuration.size)
    }
    
    func inputCellAction(index: Int) {
        guard self.isInputEnabled else {
            preconditionFailure()
        }
        
        self.inputState.setCursorPosition(to: index)
    }
    
    func handleKey(_ event: NSEvent) -> Bool {
        guard self.isInputEnabled else {
            return false
        }
        
        switch KeyActionResolver.resolveAction(event: event) {
        case .return:
            self.inputState.submit()
            
            if let equation = self.inputState.submittedEquation {
                self.gameState.addGuess(equation: equation)
                self.resetInputState()
            }
            
        case .moveLeft: self.inputState.moveCursorBackward()
            
        case .moveRight: self.inputState.moveCursorForward()
            
        case .takeLastAnswer:
            guard let lastGuess = self.gameState.guesses.last else {
                return false
            }
            
            self.inputState.setCharacters(lastGuess.equation.characters)
            
        case .clear:
            self.inputState.clear()
            
        case .space: self.inputState.inputSpace()
            
        case .delete: self.inputState.eraseBackwards()
            
        case let .character(character):
            if let character = try? ExpressionLexer().character(for: character) {
                self.inputCharacter(character)
            }
            
        case nil: return false
        }
        
        return true
    }
    
    func inputCharacter(_ character: ExpressionCharacter) {
        guard self.isInputEnabled else {
            return
        }
        
        self.inputState.input(character)
    }
    
    private func resetInputState() {
        self.inputState = GuessInputState(size: self.gameState.configuration.size)
    }
}
