//
//  InputPanel.swift
//  Nerdle
//

import NerdleKit
import SwiftUI

enum InputPanelAction {
    case character(ExpressionCharacter)
    case enter
    case delete
}

struct InputPanel: View {
    let states: [ExpressionCharacter: CharacterGameState]
    let action: (InputPanelAction) -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                ForEach(0..<10) { digit in
                    self.symbolButton(.digit(digit))
                }
            }
            
            HStack(spacing: 4) {
                ForEach(ExpressionBinop.allCases, id: \.self) { binop in
                    self.symbolButton(.binop(binop))
                }
                
                self.symbolButton(.equals)
                
                InputPanelButton(text: "Enter", isWide: true) {
                    self.action(.enter)
                }
                
                InputPanelButton(text: "Delete", isWide: true) {
                    self.action(.delete)
                }
            }
        }
    }
                        
    private func symbolButton(_ symbol: ExpressionCharacter) -> some View {
        SymbolButton(
            character: symbol,
            state: self.states[symbol],
            action: self.action
        )
    }
}

private struct SymbolButton: View {
    let character: ExpressionCharacter
    let state: CharacterGameState?
    let action: (InputPanelAction) -> Void
    
    var body: some View {
        InputPanelButton(
            text: self.character.description,
            isWide: false,
            state: self.state,
            action: {
                self.action(.character(self.character))
            }
        )
    }
}

private struct InputPanelButton: View {
    @State var isHovered = false
    
    let text: String
    let isWide: Bool
    var state: CharacterGameState? = nil
    let action: () -> Void
    
    var body: some View {
        Text(self.text)
            .font(.system(size: 15))
            .bold()
            .frame(width: self.isWide ? 60 : 25, height: 35)
            .background(self.backgroundColor)
            .overlay {
                Color.white.opacity(self.isHovered ? 0.05 : 0)
            }
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .onHover { self.isHovered = $0 }
            .onTapGesture(perform: self.action)
    }
    
    var backgroundColor: Color {
        switch self.state {
        case .correct: .green
        case .wrongPosition: .orange
        case .incorrect: .gray
        case nil: Color(white: 0.24)
        }
    }
}

#Preview {
    InputPanel(
        states: [
            .digit(2): .correct,
            .equals: .correct,
            .binop(.plus): .incorrect,
            .digit(5): .incorrect,
            .binop(.minus): .wrongPosition,
            .digit(7): .incorrect,
        ],
        action: { _ in }
    )
    .padding(8)
}
