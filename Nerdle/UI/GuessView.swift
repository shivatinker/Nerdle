//
//  GuessView.swift
//  Nerdle
//
//  Created by Andrii Zinoviev on 26.09.2024.
//

import NerdleKit
import SwiftUI

struct Grid: View {
    @StateObject var model = GameViewModel(
        target: EquationGenerator.generateRandomEquation(size: 8),
        configuration: GameConfiguration(
            size: 8,
            maxGuesses: 6
        )
    )
    
    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<self.model.gameState.configuration.maxGuesses, id: \.self) { index in
                if let guess = self.model.gameState.guesses[safe: index] {
                    GuessView(characters: guess.characters.map(CharacterModel.init))
                }
                else if index == self.model.gameState.guesses.count {
                    GuessView(
                        characters: self.model.inputState.characters.map {
                            CharacterModel(
                                character: $0,
                                state: .none
                            )
                        })
                }
                else {
                    GuessView(characters: Array(repeating: .empty, count: self.model.gameState.configuration.size))
                }
            }
        }
        .handleKeys(action: self.model.handleKey)
        .padding(16)
    }
}

private struct GuessView: View {
    let characters: [CharacterModel]
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<self.characters.count, id: \.self) { index in
                CharacterView(model: self.characters[index])
            }
        }
    }
}

private struct CharacterModel {
    let character: ExpressionCharacter?
    let state: CharacterState?
    
    init(_ character: GuessCharacter) {
        self.character = character.character
        self.state = character.state
    }
    
    init(character: ExpressionCharacter?, state: CharacterState?) {
        self.character = character
        self.state = state
    }
    
    static let empty = CharacterModel(character: nil, state: nil)
}

private struct CharacterView: View {
    let model: CharacterModel
    
    var body: some View {
        Text(self.text)
            .fontWeight(.semibold)
            .font(.system(size: 16))
            .foregroundStyle(.white)
            .frame(width: 40, height: 40)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .foregroundStyle(self.backgroundColor)
            )
    }
    
    private var text: String {
        guard let character = self.model.character else {
            return ""
        }
        
        return character.description
    }
    
    private var backgroundColor: Color {
        switch self.model.state {
        case .correct: return .green
        case .wrongPosition: return .orange
        case .incorrect: return .gray
        case nil: return Color(hex: "3b3b3b")
        }
    }
}

extension Color {
    /// Initializes a Color using a hex string (e.g., "#FFFFFF" or "FFFFFF").
    /// - Parameter hex: The hex string representing the color.
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let r, g, b, a: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b, a) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17, 255)
        case 6: // RGB (24-bit)
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8: // ARGB (32-bit)
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// #Preview {
//    Grid(size: 8, guesses: 8)
// }
