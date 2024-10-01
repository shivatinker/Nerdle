//
//  SettingsView.swift
//  Nerdle
//
//  Created by Andrii Zinoviev on 01.10.2024.
//

import Combine
import SwiftUI

struct Settings: Codable {
    var difficulty: GameDifficulty = .medium
}

struct SettingsView: View {
    let modalBridge: ModalWindowBridge
    @StateObject private var model: SettingsViewModel
    
    init(modalBridge: ModalWindowBridge, controller: SettingsController) {
        self.modalBridge = modalBridge
        self._model = StateObject(wrappedValue: SettingsViewModel(controller: controller))
    }
    
    var body: some View {
        SettingsContent(
            settings: self.$model.settings,
            close: self.modalBridge.window.close
        )
        .fixedSize(horizontal: true, vertical: false)
    }
}

@MainActor
private final class SettingsViewModel: ObservableObject {
    private var subscriptions: Set<AnyCancellable> = []
    private let controller: SettingsController
    
    var settings: Settings {
        get {
            self.controller.settings
        }
        set {
            self.controller.settings = newValue
        }
    }
    
    init(controller: SettingsController) {
        self.controller = controller
        
        self.controller.settingsDidChange
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
            .store(in: &self.subscriptions)
    }
}

private struct SettingsContent: View {
    @Binding var settings: Settings
    let close: () -> Void
    
    var body: some View {
        VStack {
            Form {
                Picker("Difficulty:", selection: self.$settings.difficulty) {
                    ForEach(GameDifficulty.allCases, id: \.self) { difficulty in
                        switch difficulty {
                        case .easy: Text("Easy (6)")
                        case .medium: Text("Medium (8)")
                        case .hard: Text("Hard (10)")
                        }
                    }
                }
                .pickerStyle(RadioGroupPickerStyle())
            }
            
            HStack {
                Spacer()
                
                Button("Close", action: self.close)
            }
        }
        .padding(16)
    }
}

#Preview {
    SettingsView(
        modalBridge: ModalWindowBridge(window: NSWindow()),
        controller: SettingsController()
    )
}
