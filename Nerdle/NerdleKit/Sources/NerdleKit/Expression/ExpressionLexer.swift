//
//  ExpressionLexer.swift
//  NerdleKit
//

public enum ExpressionCharacter: Hashable, CustomStringConvertible, Sendable {
    case digit(Int)
    case binop(ExpressionBinop)
    case equals
    
    public var description: String {
        switch self {
        case let .digit(digit):
            return String(digit)
            
        case let .binop(binop):
            return binop.rawValue

        case .equals:
            return "="
        }
    }
}

enum ExpressionToken: Equatable {
    case number(Int)
    case binop(ExpressionBinop)
    case equals
    case eof
}

// TODO: Hard Mode
public enum ExpressionBinop: String, Equatable, CaseIterable, Sendable {
    case plus = "+"
    case minus = "-"
    case multiply = "*"
    case divide = "/"
}

public struct ExpressionLexer {
    enum Error: Swift.Error {
        case invalidCharacter(Character)
    }
    
    public init() {}
    
    public func character(for character: Character) throws -> ExpressionCharacter {
        if "0"..."9" ~= character {
            return .digit(try self.digit(character: character))
        }
        
        if let binop = ExpressionBinop(rawValue: String(character)) {
            return .binop(binop)
        }
        
        if character == "=" {
            return .equals
        }
        
        throw Error.invalidCharacter(character)
    }
    
    func characters(string: String) throws -> [ExpressionCharacter] {
        try string.map {
            try self.character(for: $0)
        }
    }
    
    private func digit(character: Character) throws -> Int {
        guard let digit = Int(String(character)) else {
            assertionFailure()
            throw Error.invalidCharacter(character)
        }
        
        return digit
    }
    
    func tokens(string: String) throws -> [ExpressionToken] {
        let characters = try self.characters(string: string)
        return self.tokens(characters: characters)
    }
    
    func tokens(characters: [ExpressionCharacter]) -> [ExpressionToken] {
        var currentNumber: Int?
        var result: [ExpressionToken] = []
        
        func flushNumber() {
            guard let number = currentNumber else { return }
            result.append(.number(number))
            currentNumber = nil
        }
        
        for character in characters {
            switch character {
            case let .digit(digit):
                currentNumber = (currentNumber ?? 0) * 10 + digit
                
            case let .binop(binop):
                flushNumber()
                result.append(.binop(binop))
                
            case .equals:
                flushNumber()
                result.append(.equals)
            }
        }
        
        flushNumber()
        
        result.append(.eof)
        
        return result
    }
}
