//
//  ExpressionValidator.swift
//  NerdleKit
//

enum ExpressionValidator {
    enum Error: Swift.Error {
        case notEqual
        case divisionByZero
        case nonDivisable
        case incomplete
        case negativeResult
        case complete
    }
    
    static func complete(_ string: String) throws -> String {
        let characters = try ExpressionLexer().characters(string: string)
        let completion = try self.complete(characters)
        return String(completion)
    }
    
    static func complete(_ characters: [ExpressionCharacter]) throws -> Int {
        let tokens = ExpressionLexer().tokens(characters: characters)
        let topLevel = try ExpressionParser.parse(tokens)
        return try self.complete(topLevel)
    }
    
    static func complete(_ topLevel: ExpressionParser.TopLevel) throws -> Int {
        guard topLevel.rhs == nil else {
            throw Error.complete
        }
        
        let rhs = try self.evaluate(topLevel.lhs)
        
        guard rhs >= 0 else {
            throw Error.negativeResult
        }
        
        return rhs
    }
    
    static func validate(_ characters: [ExpressionCharacter]) throws {
        let tokens = ExpressionLexer().tokens(characters: characters)
        let topLevel = try ExpressionParser.parse(tokens)
        try self.validate(topLevel)
    }
    
    static func validate(_ topLevel: ExpressionParser.TopLevel) throws {
        guard let rhs = topLevel.rhs else {
            throw Error.incomplete
        }
        
        guard rhs >= 0 else {
            throw Error.negativeResult
        }
        
        guard try self.evaluate(topLevel.lhs) == rhs else {
            throw Error.notEqual
        }
    }
    
    private static func evaluate(_ expression: ExpressionParser.Expression) throws -> Int {
        var result = try self.evaluate(expression.terms.head)
        
        for part in expression.terms.tail {
            let value = try self.evaluate(part.value)
            result = try self.apply(result, value, part.binop)
        }
        
        return result
    }
    
    private static func evaluate(_ term: ExpressionParser.Term) throws -> Int {
        var result = term.factors.head
        
        for part in term.factors.tail {
            result = try self.apply(result, part.value, part.binop)
        }
        
        return result
    }
    
    private static func apply(_ lhs: Int, _ rhs: Int, _ binop: ExpressionBinop) throws -> Int {
        switch binop {
        case .plus:
            return lhs + rhs
        case .minus:
            return lhs - rhs
        case .multiply:
            return lhs * rhs
        case .divide:
            guard rhs != 0 else {
                throw Error.divisionByZero
            }
            
            guard lhs.isMultiple(of: rhs) else {
                throw Error.nonDivisable
            }
            
            return lhs / rhs
        }
    }
}
