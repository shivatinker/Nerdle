//
//  EquationGenerator.swift
//  NerdleKit
//

public struct EquationGenerator {
    private static let maxAttempts: Int = 1000
    private var rng: RandomNumberGenerator
    
    public init(seed: UInt64) {
        self.rng = SplitMix64(seed: seed)
    }
    
    public static func generateRandomEquation(size: Int) -> Equation {
        var generator = EquationGenerator(seed: UInt64.random(in: 0..<UInt64.max))
        return generator.generateEquation(size: size, maxAttempts: Self.maxAttempts)
    }
    
    public static func generateDailyEquation(day: Day, size: Int) -> Equation {
        let seed = UInt64(day.year * 10000 + day.month * 100 + day.day)
        var generator = EquationGenerator(seed: seed)
        return generator.generateEquation(size: size, maxAttempts: Self.maxAttempts)
    }
    
    public mutating func generateEquations(size: Int, count: Int) -> [Equation] {
        var result: [Equation] = []
        
        for _ in 0..<count {
            let equation = self.generateEquation(size: size, maxAttempts: Self.maxAttempts)
            
            result.append(equation)
        }
        
        return result
    }
    
    private mutating func generateEquation(size: Int, maxAttempts: Int) -> Equation {
        var attempts = 1
        
        for _ in 0..<maxAttempts {
            if let equation = self.generateEquation(size: size) {
                return equation
            }
            
            attempts += 1
        }
        
        preconditionFailure("Failed to generate equation after \(attempts) attempts.")
    }
    
    private mutating func generateEquation(size: Int) -> Equation? {
        var result = ""
        
        let maxNumberSize = min(size / 2, 4)
        let answerSize = Int.random(in: 1...maxNumberSize, using: &self.rng)
        
        var remainingSize = size - answerSize - 1
        
        func append(_ string: String) {
            result += string
            remainingSize -= string.count
            precondition(remainingSize >= 0)
        }
        
        var lastBinop: ExpressionBinop?
        
        while remainingSize > 0 {
            let maxNumberSize = min(maxNumberSize, remainingSize)
            let numberSize = Int.random(in: 1...maxNumberSize, using: &self.rng)
            
            let number = self.generateNumber(
                size: numberSize,
                shouldSkipOne: lastBinop == .divide // X/1 is boring, do not generate it
            )
            
            append(number)
            
            if remainingSize >= 2 {
                let binop = self.generateRandomBinop()
                lastBinop = binop
                append(binop.rawValue)
            }
        }
        
        result += "="
        
        guard let completion = try? ExpressionValidator.complete(result) else {
            return nil
        }
        
        guard completion.count == answerSize else {
            return nil
        }
        
        result += completion
        
        guard let equation = try? Equation(string: result) else {
            preconditionFailure("Expected equation to be valid at this point.")
        }
        
        return equation
    }
    
    private mutating func generateRandomBinop() -> ExpressionBinop {
        guard let op = ExpressionBinop.allCases.randomElement(using: &self.rng) else {
            preconditionFailure()
        }
        
        return op
    }
    
    private mutating func generateNumber(size: Int, shouldSkipOne: Bool = true) -> String {
        var lowerBound = self.tenPower(size - 1) // Zeroes are boring, let's set 1 as lower bound
        
        if lowerBound == 1, shouldSkipOne {
            lowerBound = 2
        }
        
        let upperBound = self.tenPower(size)
        
        let number = Int.random(in: lowerBound..<upperBound, using: &self.rng)
        return number.description
    }
    
    private func tenPower(_ power: Int) -> Int {
        precondition(power >= 0)
        
        var result = 1
        
        for _ in 0..<power {
            result *= 10
        }
        
        return result
    }
}
