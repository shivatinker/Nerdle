//
//  HistoryViewModel.swift
//  Nerdle
//

import Combine
import NerdleKit

@MainActor
final class HistoryViewModel: ObservableObject {
    private var subscriptions: Set<AnyCancellable> = []
    
    private let databaseController: DatabaseController
    
    @Published private(set) var items: [GameHistoryItem] = []
    @Published private(set) var stats: HistoryStats?
    
    private let itemAction: (GameID) -> Void
    
    init(databaseController: DatabaseController, itemAction: @escaping (GameID) -> Void) {
        self.databaseController = databaseController
        self.itemAction = itemAction
        
        self.databaseController
            .observe { db in
                try db.allGames()
            }
            .replaceError(with: [])
            .sink { self.items = $0 }
            .store(in: &self.subscriptions)
        
        self.databaseController
            .observe { db in
                try db.stats()
            }
            .replaceError(with: nil)
            .sink { self.stats = $0 }
            .store(in: &self.subscriptions)
    }
    
    func itemAction(_ gameID: GameID) {
        self.itemAction(gameID)
    }
}
