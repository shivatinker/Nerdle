//
//  InputPanel.swift
//  Nerdle
//
//  Created by Andrii Zinoviev on 27.09.2024.
//

import NerdleKit
import SwiftUI

enum InputPanelAction {
    case character(ExpressionCharacter)
    case enter
    case delete
}

struct InputPanel: View {
    let action: (InputPanelAction) -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                ForEach(0..<10) { digit in
                    SymbolButton(character: .digit(digit), action: self.action)
                }
            }
            
            HStack(spacing: 4) {
                ForEach(ExpressionBinop.allCases, id: \.self) { binop in
                    SymbolButton(character: .binop(binop), action: self.action)
                }
                
                SymbolButton(character: .equals, action: self.action)
                
                InputPanelButton(text: "Enter", isWide: true) {
                    self.action(.enter)
                }
                
                InputPanelButton(text: "Delete", isWide: true) {
                    self.action(.delete)
                }
            }
        }
    }
}

private struct SymbolButton: View {
    let character: ExpressionCharacter
    let action: (InputPanelAction) -> Void
    
    var body: some View {
        InputPanelButton(
            text: self.character.description,
            isWide: false,
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
    let action: () -> Void
    
    var body: some View {
        Text(self.text)
            .font(.system(size: 15))
            .bold()
            .frame(width: self.isWide ? 60 : 25, height: 35)
            .background(Color(white: 0.24))
            .overlay {
                Color.white.opacity(self.isHovered ? 0.05 : 0)
            }
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .onHover { self.isHovered = $0 }
            .onTapGesture(perform: self.action)
    }
}

#Preview {
    InputPanel { _ in }
        .padding(8)
}
