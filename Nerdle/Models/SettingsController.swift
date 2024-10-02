//
//  SettingsController.swift
//  Nerdle
//

import Combine
import Foundation

@MainActor
final class SettingsController {
    var settings: Settings {
        didSet {
            self._settingsDidChange.send()
            self.save()
        }
    }
    
    var settingsDidChange: AnyPublisher<Void, Never> {
        self._settingsDidChange.eraseToAnyPublisher()
    }
    
    private let _settingsDidChange = PassthroughSubject<Void, Never>()
    
    init() {
        self.settings = Self.load()
    }
    
    private func save() {
        do {
            let data = try JSONEncoder().encode(self.settings)
            UserDefaults.standard.set(data, forKey: "settings")
        }
        catch {
            print("Failed to save settings: \(error)")
        }
    }
    
    private static func load() -> Settings {
        guard let data = UserDefaults.standard.data(forKey: "settings") else {
            return Settings()
        }
        
        do {
            return try JSONDecoder().decode(Settings.self, from: data)
        }
        catch {
            print("Failed to load settings: \(error)")
            return Settings()
        }
    }
}
