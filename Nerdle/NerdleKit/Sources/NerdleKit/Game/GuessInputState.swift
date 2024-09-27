//
//  GuessInputState.swift
//  NerdleKit
//
//  Created by Andrii Zinoviev on 27.09.2024.
//

public struct GuessInputState: CustomStringConvertible {
    public let size: Int
    
    public private(set) var characters: [ExpressionCharacter?] {
        didSet {
            self.validateInputIfNeeded()
        }
    }

    public private(set) var cursorPosition: Int = 0
    
    public private(set) var submittedEquation: Equation?
    public private(set) var error: Error?
    
    public init(size: Int) {
        precondition(size > 0)
        
        self.size = size
        self.characters = Array(repeating: nil, count: size)
    }
    
    public mutating func input(string: String) {
        guard let characters = try? ExpressionLexer().characters(string: string) else {
            return
        }
        
        for character in characters {
            if self.cursorPosition == self.size - 1,
               self.characters[self.cursorPosition] != nil
            {
                break
            }
            
            self.input(character)
        }
    }
    
    public mutating func input(_ character: ExpressionCharacter) {
        self.characters[self.cursorPosition] = character
        
        // TODO: check only empty spaces ahead
        if self.unwrappedCharacters() == nil {
            // Move cursor to next empty cell
            while self.cursorPosition < self.size - 1 {
                if self.characters[self.cursorPosition] != nil {
                    self.cursorPosition += 1
                }
                else {
                    break
                }
            }
        }
        else {
            // Move cursor to next cell
            if self.cursorPosition < self.size - 1 {
                self.cursorPosition += 1
            }
        }
    }
    
    @discardableResult
    private mutating func validateInputIfNeeded() -> Equation? {
        self.error = nil
        
        guard let characters = self.unwrappedCharacters() else {
            return nil
        }
        
        do {
            return try Equation(characters: characters)
        }
        catch {
            self.error = error
            return nil
        }
    }
    
    public mutating func inputSpace() {
        self.characters[self.cursorPosition] = nil
        
        if self.cursorPosition < self.size - 1 {
            self.cursorPosition += 1
        }
    }
    
    public mutating func submit() {
        precondition(self.submittedEquation == nil)
        self.submittedEquation = self.validateInputIfNeeded()
    }
    
    public mutating func eraseBackwards() {
        if self.characters[self.cursorPosition] != nil {
            self.characters[self.cursorPosition] = nil
            return
        }
        
        if self.cursorPosition == 0 {
            return
        }
        
        self.cursorPosition -= 1
        self.characters[self.cursorPosition] = nil
    }
    
    public mutating func setCursorPosition(to position: Int) {
        precondition(position >= 0 && position < self.size)
        self.cursorPosition = position
    }
    
    public mutating func moveCursorForward() {
        if self.cursorPosition < self.size - 1 {
            self.cursorPosition += 1
        }
    }
    
    public mutating func moveCursorBackward() {
        if self.cursorPosition > 0 {
            self.cursorPosition -= 1
        }
    }
    
    private func unwrappedCharacters() -> [ExpressionCharacter]? {
        let characters = self.characters.compactMap(\.self)
        
        guard characters.count == self.size else {
            return nil
        }
        
        return characters
    }
    
    public var description: String {
        self.characters
            .map { character in
                if let character {
                    return character.description
                }
                else {
                    return "_"
                }
            }
            .joined()
    }
}
