//
//  GameState.swift
//  NerdleKit
//
//  Created by Andrii Zinoviev on 27.09.2024.
//

public struct GameConfiguration: Codable, Equatable {
    public let size: Int
    public let maxGuesses: Int
    
    public init(size: Int, maxGuesses: Int) {
        self.size = size
        self.maxGuesses = maxGuesses
    }
}

public enum GameTermination {
    case won
    case lost
}

public struct GameState: Codable, Equatable {
    public let target: Equation
    public let configuration: GameConfiguration
    
    public private(set) var guesses: [Guess] = []
    
    public init(target: Equation, configuration: GameConfiguration) {
        precondition(target.characters.count == configuration.size)
        
        self.target = target
        self.configuration = configuration
    }
    
    public var termination: GameTermination? {
        precondition(self.guesses.count <= self.configuration.maxGuesses)
        
        if self.guesses.contains(where: \.states.isCorrect) {
            return .won
        }
        
        if self.guesses.count == self.configuration.maxGuesses {
            return .lost
        }
        
        return nil
    }
    
    public mutating func addGuess(equation: Equation) {
        precondition(self.termination == nil)
        
        let guessResolver = GuessResolver(target: self.target)
        let guess = guessResolver.resolve(equation)
        
        self.guesses.append(guess)
    }
}
