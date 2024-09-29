//
//  HistoryViewModel.swift
//  Nerdle
//
//  Created by Andrii Zinoviev on 29.09.2024.
//

import Combine
import NerdleKit

@MainActor
final class HistoryViewModel: ObservableObject {
    private var subscriptions: Set<AnyCancellable> = []
    
    private let databaseController: DatabaseController
    
    @Published private(set) var items: [GameHistoryItem] = []
    @Published private(set) var stats: HistoryStats?
    
    init(databaseController: DatabaseController) {
        self.databaseController = databaseController
        
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
}
