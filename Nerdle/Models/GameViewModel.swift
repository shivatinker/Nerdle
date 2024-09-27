//
//  GameViewModel.swift
//  Nerdle
//
//  Created by Andrii Zinoviev on 27.09.2024.
//

import AppKit
import Carbon
import Combine
import NerdleKit

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var gameState: GameState
    @Published private(set) var inputState: GuessInputState
    
    init(target: Equation, configuration: GameConfiguration) {
        self.gameState = GameState(target: target, configuration: configuration)
        self.inputState = GuessInputState(size: configuration.size)
    }
    
    func handleKey(_ event: NSEvent) {
        if self.gameState.termination != nil {
            return
        }
        
        if event.keyCode == kVK_Return {
            self.inputState.submit()
            
            if let equation = self.inputState.submittedEquation {
                self.gameState.addGuess(equation: equation)
                self.resetInputState()
            }
            
            return
        }
        
        if event.keyCode == kVK_Delete || event.keyCode == kVK_ForwardDelete {
            self.inputState.eraseBackwards()
            return
        }
        
        guard let character = event.characters?.first else {
            return
        }
        
        guard let character = try? ExpressionLexer().character(for: character) else {
            return
        }
        
        self.inputCharacter(character)
    }
    
    private func resetInputState() {
        self.inputState = GuessInputState(size: self.gameState.configuration.size)
    }
    
    private func inputCharacter(_ character: ExpressionCharacter) {
        self.inputState.input(character)
    }
}
