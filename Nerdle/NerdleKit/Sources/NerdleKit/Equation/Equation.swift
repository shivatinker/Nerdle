//
//  Equation.swift
//  NerdleKit
//

public struct Equation: Codable, CustomStringConvertible, Equatable {
    public let characters: [ExpressionCharacter]
    
    init(characters: [ExpressionCharacter]) throws {
        try ExpressionValidator.validate(characters)
        self.characters = characters
    }
    
    public init(string: String) throws {
        let characters = try ExpressionLexer().characters(string: string)
        try self.init(characters: characters)
    }
    
    func countCharacters() -> [ExpressionCharacter: Int] {
        var result: [ExpressionCharacter: Int] = [:]
        self.characters.forEach { result[$0, default: 0] += 1 }
        return result
    }
    
    public var description: String {
        self.characters.map(\.description).joined()
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
