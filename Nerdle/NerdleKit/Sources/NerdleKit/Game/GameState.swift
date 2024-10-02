//
//  GameState.swift
//  NerdleKit
//

public struct GameConfiguration: Codable, Equatable {
    public let size: Int
    public let maxGuesses: Int
    
    public init(size: Int, maxGuesses: Int) {
        self.size = size
        self.maxGuesses = maxGuesses
    }
}

public enum GameTermination: String, Codable {
    case won
    case lost
}

public struct GameState: Codable, Equatable {
    enum Error: Swift.Error {
        case notTerminated
    }
    
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
    
    public func characterGameStates() -> [ExpressionCharacter: CharacterGameState] {
        var result: [ExpressionCharacter: CharacterGameState] = [:]
        
        for guess in self.guesses {
            for character in guess.characters {
                let oldValue = result[character.character, default: .incorrect]
                let newValue = self.gameState(character.state)
                result[character.character] = max(oldValue, newValue)
            }
        }
        
        return result
    }
    
    private func gameState(_ state: CharacterState) -> CharacterGameState {
        switch state {
        case .correct: .correct
        case .wrongPosition: .wrongPosition
        case .incorrect: .incorrect
        }
    }
    
    public func export() throws -> String {
        guard let termination else {
            throw Error.notTerminated
        }
        
        return """
        Nerdle [\(self.target.description)]: \(termination)
        \(self.guesses.map(self.guessText).joined(separator: "\n"))
        """
    }
    
    private func guessText(_ guess: Guess) -> String {
        guess.characters
            .map {
                switch $0.state {
                case .correct: "🟩"
                case .wrongPosition: "🟨"
                case .incorrect: "⬛"
                }
            }
            .joined()
    }
}

public enum CharacterGameState: Comparable {
    case incorrect
    case wrongPosition
    case correct
}
