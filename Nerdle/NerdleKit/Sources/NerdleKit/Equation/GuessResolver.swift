//
//  GuessResolver.swift
//  NerdleKit
//
//  Created by Andrii Zinoviev on 26.09.2024.
//

public enum CharacterState: String {
    case correct = "C"
    case wrongPosition = "W"
    case incorrect = "X"
}

public struct GuessCharacter {
    public let character: ExpressionCharacter
    public let state: CharacterState
}

public struct Guess: Codable, Equatable {
    public let equation: Equation
    public let states: CharacterStates
    
    public var characters: [GuessCharacter] {
        zip(self.equation.characters, self.states.states).map {
            GuessCharacter(
                character: $0,
                state: $1
            )
        }
    }
}

public struct CharacterStates: Codable, CustomStringConvertible, Equatable {
    enum Error: Swift.Error {
        case invalidCharacter
    }
    
    public let states: [CharacterState]
    
    init(_ states: [CharacterState]) {
        self.states = states
    }
    
    init(string: String) throws {
        self.states = try string.map {
            guard let state = CharacterState(rawValue: String($0)) else {
                throw Error.invalidCharacter
            }
            
            return state
        }
    }
    
    public var isCorrect: Bool {
        self.states.allSatisfy { $0 == .correct }
    }
    
    public var description: String {
        self.states.map(\.rawValue).joined()
    }
    
    // MARK: Codable
    
    public func encode(to encoder: any Encoder) throws {
        let string = self.description
        var container = encoder.singleValueContainer()
        try container.encode(string)
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        try self.init(string: string)
    }
}

public struct GuessResolver {
    public let target: Equation
    
    public init(target: Equation) {
        self.target = target
    }
    
    public func resolve(_ guess: Equation) -> Guess {
        precondition(guess.characters.count == self.target.characters.count)
        
        var characters = self.target.countCharacters()
        
        var result = Array(
            repeating: CharacterState.incorrect,
            count: self.target.characters.count
        )
        
        for (index, character) in guess.characters.enumerated() {
            if self.target.characters[index] == character {
                result[index] = .correct
                characters[character, default: 1] -= 1
            }
        }
        
        for (index, character) in guess.characters.enumerated() {
            if result[index] == .correct {
                continue
            }
            
            if let remainingCount = characters[character],
               remainingCount > 0
            {
                characters[character, default: 1] -= 1
                result[index] = .wrongPosition
            }
            else {
                result[index] = .incorrect
            }
        }
        
        return Guess(equation: guess, states: CharacterStates(result))
    }
}
