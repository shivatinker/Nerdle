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
            self.suggestCompletionIfNeeded()
        }
    }

    public private(set) var cursorPosition: Int = 0
    
    public private(set) var submittedEquation: Equation?
    public private(set) var error: Error?
    
    public private(set) var completion: [ExpressionCharacter]?
    
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
        self.moveCursorForward()
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
        self.moveCursorForward()
    }
    
    public mutating func submit() {
        precondition(self.submittedEquation == nil)
        
        if self.completion != nil {
            self.acceptCompletion()
        }
        else {
            self.submittedEquation = self.validateInputIfNeeded()
        }
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

    public mutating func setCharacters(_ characters: [ExpressionCharacter]) {
        self.characters = characters
    }
    
    public mutating func clear() {
        self.characters = Array(repeating: nil, count: self.size)
    }
    
    private func unwrappedCharacters() -> [ExpressionCharacter]? {
        let characters = self.characters.compactMap(\.self)
        
        guard characters.count == self.size else {
            return nil
        }
        
        return characters
    }
    
    // MARK: Completion
    
    public mutating func acceptCompletion() {
        guard let completion else {
            return
        }
        
        for index in 0..<completion.count {
            self.characters[index + self.size - completion.count] = completion[index]
        }
        
        self.cursorPosition = self.size - 1
    }
    
    private mutating func suggestCompletionIfNeeded() {
        self.completion = self.completionString()
    }
    
    private func completionString() -> [ExpressionCharacter]? {
        guard let lastCharacterIndex = self.characters.lastIndex(where: { $0 != nil }) else {
            return nil
        }
        
        var characters = self.characters[0...lastCharacterIndex]
        
        guard characters.allSatisfy({ $0 != nil }) else {
            return nil
        }
        
        var didAppendEquals = false
        
        if characters.last != .equals {
            characters.append(.equals)
            didAppendEquals = true
        }
        
        guard let completion = try? ExpressionValidator.complete(Array(characters.compactMap(\.self))) else {
            return nil
        }
        
        let result = String(completion)
        
        guard result.count == self.size - characters.count else {
            return nil
        }
        
        guard let completion = try? ExpressionLexer().characters(string: result) else {
            return nil
        }
        
        if didAppendEquals {
            return [.equals] + completion
        }
        else {
            return completion
        }
    }
    
    // MARK: Description
    
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
