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
        let size = self.model.gameState.configuration.size
        
        VStack(spacing: 4) {
            ForEach(0..<self.model.gameState.configuration.maxGuesses, id: \.self) { index in
                if let guess = self.model.gameState.guesses[safe: index] {
                    self.rowView(guess.characters.map(CharacterModel.init))
                        .disabled(true)
                }
                else if index == self.model.gameState.guesses.count, self.model.isInputEnabled {
                    self.rowView(
                        self.model.inputState.characters.enumerated().map { index, character in
                            CharacterModel(
                                character: character,
                                state: .none,
                                isSelected: index == self.model.inputState.cursorPosition
                            )
                        }
                    )
                }
                else {
                    self.rowView(Array(repeating: .empty, count: size))
                        .disabled(true)
                }
            }
        }
        .handleKeys(action: self.model.handleKey)
        .padding(16)
    }
    
    private func rowView(_ characters: [CharacterModel]) -> some View {
        GuessView(
            characters: characters,
            action: self.model.inputCellAction(index:)
        )
    }
}

private struct GuessView: View {
    let characters: [CharacterModel]
    let action: (Int) -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<self.characters.count, id: \.self) { index in
                CharacterView(
                    model: self.characters[index],
                    action: { self.action(index) }
                )
            }
        }
    }
}

private struct CharacterModel {
    let character: ExpressionCharacter?
    let state: CharacterState?
    let isSelected: Bool
    
    init(_ character: GuessCharacter) {
        self.character = character.character
        self.state = character.state
        self.isSelected = false
    }
    
    init(character: ExpressionCharacter?, state: CharacterState?, isSelected: Bool) {
        self.character = character
        self.state = state
        self.isSelected = isSelected
    }
    
    static let empty = CharacterModel(character: nil, state: nil, isSelected: false)
}

private struct CharacterView: View {
    @Environment(\.isEnabled) var isEnabled: Bool
    @State var isHovered: Bool = false
    
    let model: CharacterModel
    let action: () -> Void
    
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
            .overlay {
                if self.model.isSelected {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.white, lineWidth: 1)
                }
            }
            .onHover {
                self.isHovered = $0
            }
            .onTapGesture(perform: self.action)
    }
    
    private var text: String {
        guard let character = self.model.character else {
            return ""
        }
        
        return character.description
    }
    
    private var backgroundColor: Color {
        switch self.model.state {
        case .correct: .green
        case .wrongPosition: .orange
        case .incorrect: .gray
        case nil: (self.isHovered && self.isEnabled) ? Color(white: 0.33) : Color(white: 0.24)
        }
    }
}

#Preview {
    CharacterView(
        model: CharacterModel(
            character: .digit(7),
            state: .none,
            isSelected: true
        ),
        action: { print("action") }
    )
    .padding(8)
}
