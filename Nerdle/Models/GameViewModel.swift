//
//  GameViewModel.swift
//  Nerdle
//
//  Created by Andrii Zinoviev on 27.09.2024.
//

import AppKit
import Combine
import NerdleKit

@MainActor
final class GameViewModel: ObservableObject {
    private let databaseController: DatabaseController
    
    @Published private(set) var gameState: GameState
    @Published private(set) var inputState: GuessInputState
    @Published var isHistoryVisible = false
    
    var isInputEnabled: Bool {
        self.gameState.termination == nil
    }
    
    var isNewGameEnabled: Bool {
        self.gameState.termination != nil
    }
    
    init(
        target: Equation,
        configuration: GameConfiguration,
        databaseController: DatabaseController
    ) {
        self.gameState = GameState(target: target, configuration: configuration)
        self.inputState = GuessInputState(size: configuration.size)
        self.databaseController = databaseController
        
        self.loadSavedGameIfPossible()
        self.subscribeToNotifications()
    }
    
    func inputCellAction(index: Int) {
        guard self.isInputEnabled else {
            preconditionFailure()
        }
        
        self.inputState.setCursorPosition(to: index)
    }
    
    func handleInputPanelAction(_ action: InputPanelAction) {
        guard self.isInputEnabled else {
            return
        }
        
        switch action {
        case let .character(character):
            self.inputCharacter(character)
            
        case .enter:
            self.submit()
            
        case .delete:
            self.inputState.eraseBackwards()
        }
    }
    
    private func submit() {
        if let equation = self.inputState.submit() {
            self.gameState.addGuess(equation: equation)
            self.resetInputState()
            
            if self.gameState.termination != nil {
                do {
                    try self.databaseController.write { db in
                        let id = try db.logGame(state: self.gameState, date: .now)
                        print("Saved game with id \(id)")
                    }
                }
                catch {
                    print("Failed to save game results: \(error).")
                }
            }
        }
    }
    
    func handleKey(_ event: NSEvent) -> Bool {
        guard self.isInputEnabled else {
            return false
        }
        
        switch KeyActionResolver.resolveAction(event: event) {
        case .return:
            self.submit()
            
        case .moveLeft: self.inputState.moveCursorBackward()
            
        case .moveRight: self.inputState.moveCursorForward()
            
        case .takeLastAnswer:
            guard let lastGuess = self.gameState.guesses.last else {
                return false
            }
            
            self.inputState.substituteLastGuess(lastGuess.equation)
            
        case .clear:
            self.inputState.clear()
            
        case .space: self.inputState.inputSpace()
            
        case .delete: self.inputState.eraseBackwards()
            
        case let .character(character):
            if let character = try? ExpressionLexer().character(for: character) {
                self.inputCharacter(character)
            }
            
        case nil: return false
        }
        
        return true
    }
    
    func inputCharacter(_ character: ExpressionCharacter) {
        guard self.isInputEnabled else {
            return
        }
        
        self.inputState.input(character)
    }
    
    private func resetInputState() {
        self.inputState = GuessInputState(size: self.gameState.configuration.size)
    }
    
    func startNewGame() {
        precondition(self.isNewGameEnabled)
        
        self.gameState = GameState(
            target: EquationGenerator.generateRandomEquation(
                size: self.gameState.configuration.size
            ),
            configuration: self.gameState.configuration
        )
        
        self.resetInputState()
    }
    
    func loadGame(id: GameID) {
        do {
            self.gameState = try self.databaseController.read { db in
                try db.gameState(id: id)
            }
            
            self.resetInputState()
        }
        catch {
            print("Failled to load game: \(error)")
        }
    }
    
    func makeHistoryViewModel() -> HistoryViewModel {
        HistoryViewModel(databaseController: self.databaseController) { [weak self] in
            self?.loadGame(id: $0)
        }
    }
    
    // MARK: State loading
    
    private static let savedGameKey = "savedGame"
    
    private func loadSavedGameIfPossible() {
        guard let data = UserDefaults.standard.data(forKey: GameViewModel.savedGameKey) else {
            return
        }
        
        do {
            self.gameState = try JSONDecoder().decode(GameState.self, from: data)
        }
        catch {
            print("Failed to load saved game state: \(error)")
        }
        
        UserDefaults.standard.removeObject(forKey: GameViewModel.savedGameKey)
    }
    
    private func saveGameIfNeeded() {
        if self.gameState.termination == nil {
            do {
                let data = try JSONEncoder().encode(self.gameState)
                UserDefaults.standard.set(data, forKey: GameViewModel.savedGameKey)
            }
            catch {
                print("Failed to save game state: \(error)")
            }
        }
    }
    
    // MARK: Notifications
    
    func subscribeToNotifications() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(
            self,
            selector: #selector(self.applicationWillTerminate),
            name: NSApplication.willTerminateNotification,
            object: nil
        )
    }
    
    @objc
    private func applicationWillTerminate() {
        self.saveGameIfNeeded()
    }
}
