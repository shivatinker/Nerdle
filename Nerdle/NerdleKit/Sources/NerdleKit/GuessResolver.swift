//
//  GuessResolver.swift
//  NerdleKit
//
//  Created by Andrii Zinoviev on 26.09.2024.
//

enum CharacterState {
    case correct
    case wrongPosition
    case incorrect
}

struct GuessResolver {
    let target: Equation
    
    func resolve(_ guess: Equation) -> [CharacterState] {
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
            else if let remainingCount = characters[character],
                    remainingCount > 0
            {
                characters[character, default: 1] -= 1
                result[index] = .wrongPosition
            }
            else {
                result[index] = .incorrect
            }
        }
        
        return result
    }
}
