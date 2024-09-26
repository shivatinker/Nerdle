//
//  ExpressionValidator.swift
//  NerdleKit
//
//  Created by Andrii Zinoviev on 26.09.2024.
//

enum ExpressionValidator {
    enum Error: Swift.Error {
        case notEqual
        case divisionByZero
        case incomplete
        case complete
    }
    
    static func complete(_ topLevel: ExpressionParser.TopLevel) throws -> Int {
        guard topLevel.rhs == nil else {
            throw Error.complete
        }
        
        return try self.evaluate(topLevel.lhs)
    }
    
    static func validate(_ topLevel: ExpressionParser.TopLevel) throws {
        guard let rhs = topLevel.rhs else {
            throw Error.incomplete
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
            
            return lhs / rhs
        }
    }
}
