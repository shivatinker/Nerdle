//
//  ExpressionParser.swift
//  NerdleKit
//
//  Created by Andrii Zinoviev on 26.09.2024.
//

struct ExpressionParser {
    struct TopLevel: Equatable {
        let lhs: Expression
        let rhs: Int?
    }
    
    struct Expression: Equatable {
        let terms: BinopList<Term>
    }
    
    struct Term: Equatable {
        let factors: BinopList<Int>
    }
    
    struct BinopList<T: Equatable>: Equatable {
        let head: T
        var tail: [BinopPart<T>]
        
        init(head: T, tail: [BinopPart<T>] = []) {
            self.head = head
            self.tail = tail
        }
    }
    
    struct BinopPart<T: Equatable>: Equatable {
        let value: T
        let binop: ExpressionBinop
    }
    
    enum Error: Swift.Error {
        case expectedToken
        case expectedEquals
        case expectedNumber
        case expectedEOF
    }
    
    private var tokens: [ExpressionToken]
    private var currentIndex = 0
    
    private var currentToken: ExpressionToken {
        self.tokens[self.currentIndex]
    }
    
    private init(_ tokens: [ExpressionToken]) {
        self.tokens = tokens
    }
    
    static func parse(_ tokens: [ExpressionToken]) throws -> TopLevel {
        var parser = ExpressionParser(tokens)
        return try parser.parse()
    }
    
    private mutating func parse() throws -> TopLevel {
        let lhs = try self.parseExpression()
        
        guard self.currentToken == .equals else {
            throw Error.expectedEquals
        }
        
        self.next() // Eat "="
        
        if self.currentToken == .eof {
            return TopLevel(lhs: lhs, rhs: nil)
        }
        
        let rhs = try self.parseNumber()
        
        guard self.currentToken == .eof else {
            throw Error.expectedEOF
        }
        
        return TopLevel(lhs: lhs, rhs: rhs)
    }
    
    private mutating func parseExpression() throws -> Expression {
        var result = BinopList<Term>(head: try self.parseTerm())
        
        while true {
            guard case let .binop(binop) = self.currentToken,
                  binop == .plus || binop == .minus
            else {
                break
            }
            
            self.next() // Eat operation
            result.tail.append(
                BinopPart(
                    value: try self.parseTerm(),
                    binop: binop
                )
            )
        }
        
        return Expression(terms: result)
    }
    
    private mutating func parseTerm() throws -> Term {
        var result = BinopList<Int>(head: try self.parseNumber())
        
        while true {
            guard case let .binop(binop) = self.currentToken,
                  binop == .multiply || binop == .divide
            else {
                break
            }
            
            self.next() // Eat operation
            result.tail.append(
                BinopPart(
                    value: try self.parseNumber(),
                    binop: binop
                )
            )
        }
        
        return Term(factors: result)
    }
    
    private mutating func parseNumber() throws -> Int {
        guard case let .number(value) = currentToken else {
            throw Error.expectedNumber
        }
        
        self.next()
        return value
    }
    
    private mutating func next() {
        if self.currentToken == .eof {
            fatalError()
        }
        
        self.currentIndex += 1
    }
}
