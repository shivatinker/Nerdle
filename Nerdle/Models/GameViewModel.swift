//
//  GameViewModel.swift
//  Nerdle
//
//  Created by Andrii Zinoviev on 27.09.2024.
//

import AppKit
import Combine
import NerdleKit

enum GameDifficulty: CaseIterable, Codable {
    case easy
    case medium
    case hard
    
    func makeConfiguration() -> GameConfiguration {
        switch self {
        case .easy: GameConfiguration(size: 6, maxGuesses: 6)
        case .medium: GameConfiguration(size: 8, maxGuesses: 6)
        case .hard: GameConfiguration(size: 10, maxGuesses: 6)
        }
    }
}

@MainActor
final class GameViewModel: ObservableObject {
    private var subscriptions: Set<AnyCancellable> = []
    
    private let settingsController: SettingsController
    private let databaseController: DatabaseController
    
    @Published private(set) var mode: GameMode = .practice
    @Published private(set) var gameState: GameState!
    @Published private(set) var inputState: GuessInputState!
    
    var difficulty: GameDifficulty {
        self.settingsController.settings.difficulty
    }
    
    var isInputEnabled: Bool {
        self.gameState.termination == nil
    }
    
    var isNewGameEnabled: Bool {
        self.gameState.termination != nil
    }
    
    init(
        databaseController: DatabaseController,
        settingsController: SettingsController
    ) {
        self.databaseController = databaseController
        self.settingsController = settingsController
        
        if false == self.loadSavedGameIfPossible() {
            self.loadCurrentDailyGame()
        }
        
        self.subscribeToNotifications()
        
        self.settingsController.settingsDidChange
            .sink { [weak self] in
                self?.objectWillChange.send()
                self?.handleDifficultyChange()
            }
            .store(in: &self.subscriptions)
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
                        let id = try db.logGame(state: self.gameState, date: .now, mode: self.mode)
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
    
    private static func makeNewGameState(difficulty: GameDifficulty) -> GameState {
        let configuration = difficulty.makeConfiguration()
        
        return GameState(
            target: EquationGenerator.generateRandomEquation(
                size: configuration.size
            ),
            configuration: configuration
        )
    }
    
    func makeHistoryViewModel() -> HistoryViewModel {
        HistoryViewModel(databaseController: self.databaseController) { [weak self] in
            self?.loadGame(id: $0)
        }
    }
    
    // MARK: Game Loading
    
    func startCustomGame(equation: Equation) {
        self.loadGame(
            state: GameState(
                target: equation,
                configuration: GameConfiguration(
                    size: equation.characters.count,
                    maxGuesses: 6
                )
            ),
            mode: .practice
        )
    }
    
    func startNewPracticeGame() {
        self.loadGame(
            state: Self.makeNewGameState(difficulty: self.difficulty),
            mode: .practice
        )
    }
    
    private func handleDifficultyChange() {
        if self.gameState.guesses.isEmpty, self.mode == .practice {
            self.startNewPracticeGame()
        }
    }
    
    func loadCurrentDailyGame() {
        let day = Day(date: .now)
        
        let game = try? self.databaseController.read { db in
            try db.game(day: day)
        }
        
        if let game {
            self.loadGame(state: game.state, mode: game.mode)
            return
        }
        
        let configuration = GameDifficulty.medium.makeConfiguration()
        
        let state = GameState(
            target: EquationGenerator.generateDailyEquation(day: day, size: configuration.size),
            configuration: configuration
        )
        
        self.loadGame(state: state, mode: .daily(day))
    }
    
    func loadGame(id: GameID) {
        do {
            let game = try self.databaseController.read { db in
                try db.game(id: id)
            }
            
            self.loadGame(state: game.state, mode: game.mode)
        }
        catch {
            print("Failled to load game: \(error)")
        }
    }
    
    private func loadGame(state: GameState, mode: GameMode) {
        self.gameState = state
        self.mode = mode
        self.resetInputState()
    }
    
    // MARK: Share
    
    var isShareEnabled: Bool {
        self.gameState.termination != nil
    }
    
    func shareGame() -> String? {
        precondition(self.isShareEnabled)
        
        do {
            return try self.gameState.export()
        }
        catch {
            print("Failed to export game: \(error)")
            return nil
        }
    }
    
    // MARK: State loading
    
    private static let savedGameKey = "savedGame"
    
    private func loadSavedGameIfPossible() -> Bool {
        guard let data = UserDefaults.standard.data(forKey: GameViewModel.savedGameKey) else {
            return false
        }
        
        defer {
            UserDefaults.standard.removeObject(forKey: GameViewModel.savedGameKey)
        }
        
        do {
            self.loadGame(
                state: try JSONDecoder().decode(GameState.self, from: data),
                mode: .practice // FIX!!!
            )
            
            return true
        }
        catch {
            print("Failed to load saved game state: \(error)")
            return false
        }
    }
    
    private func saveGameIfNeeded() {
        if self.gameState.termination == nil, self.gameState.guesses.isEmpty == false {
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
