//
//  Equation.swift
//  NerdleKit
//
//  Created by Andrii Zinoviev on 26.09.2024.
//

struct Equation {
    let characters: [ExpressionCharacter]
    
    init(characters: [ExpressionCharacter]) throws {
        try ExpressionValidator.validate(characters)
        self.characters = characters
    }
    
    init(string: String) throws {
        let characters = try ExpressionLexer().characters(string: string)
        try self.init(characters: characters)
    }
    
    func countCharacters() -> [ExpressionCharacter: Int] {
        var result: [ExpressionCharacter: Int] = [:]
        self.characters.forEach { result[$0, default: 0] += 1 }
        return result
    }
}
