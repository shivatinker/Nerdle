//
//  ExpressionLexer.swift
//  NerdleKit
//
//  Created by Andrii Zinoviev on 26.09.2024.
//

enum ExpressionCharacter: Hashable {
    case digit(Int)
    case binop(ExpressionBinop)
    case equals
}

enum ExpressionToken: Equatable {
    case number(Int)
    case binop(ExpressionBinop)
    case equals
    case eof
}

enum ExpressionBinop: Equatable {
    case plus
    case minus
    case multiply
    case divide
}

struct ExpressionLexer {
    enum Error: Swift.Error {
        case invalidCharacter(Character)
    }
    
    func characters(string: String) throws -> [ExpressionCharacter] {
        try string.map {
            switch $0 {
            case "0"..."9": .digit(try self.digit(character: $0))
            case "+": .binop(.plus)
            case "-": .binop(.minus)
            case "*": .binop(.multiply)
            case "/": .binop(.divide)
            case "=": .equals
            default: throw Error.invalidCharacter($0)
            }
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
