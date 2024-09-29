//
//  HistoryView.swift
//  Nerdle
//
//  Created by Andrii Zinoviev on 29.09.2024.
//

import Combine
import NerdleKit
import SwiftUI

struct HistoryView: View {
    @StateObject var model: HistoryViewModel
    
    init(model: @escaping () -> HistoryViewModel) {
        self._model = StateObject(wrappedValue: model())
    }
    
    var body: some View {
        List(self.model.items) { item in
            HistoryListItem(
                id: item.id,
                termination: item.termination,
                date: item.date
            )
        }
        .frame(width: 200)
    }
}

private struct HistoryListItem: View {
    let id: GameID
    let termination: GameTermination
    let date: Date
    
    var body: some View {
        VStack(alignment: .leading) {
            self.terminationText
                .font(.headline)
            Text(self.formattedDate)
                .font(.subheadline)
        }
        .padding([.leading, .trailing], 6)
    }
    
    @ViewBuilder
    private var terminationText: some View {
        switch self.termination {
        case .won:
            Text("Won")
                .foregroundStyle(.green)
        case .lost:
            Text("Lost")
                .foregroundStyle(.red)
        }
    }
    
    private var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: self.date, relativeTo: .now)
    }
}

@MainActor
final class HistoryViewModel: ObservableObject {
    private var subscriptions: Set<AnyCancellable> = []
    
    private let databaseController: DatabaseController
    
    @Published private(set) var items: [GameHistoryItem] = []
    
    init(databaseController: DatabaseController) {
        self.databaseController = databaseController
        
        self.databaseController
            .observe { db in
                try db.allGames()
            }
            .replaceError(with: [])
            .sink { self.items = $0 }
            .store(in: &self.subscriptions)
    }
}

#Preview {
    VStack {
        HistoryListItem(id: 2, termination: .won, date: Date(timeIntervalSince1970: 1727610440))
        HistoryListItem(id: 1, termination: .lost, date: Date(timeIntervalSince1970: 1727610396))
    }
    .frame(width: 200, alignment: .leading)
}
