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
        HistoryViewContent(
            items: self.model.items.map { item in
                HistoryListItem(
                    id: item.id,
                    termination: item.termination,
                    date: item.date,
                    configuraiton: item.state.configuration,
                    guessCount: item.state.guesses.count
                )
            },
            stats: self.model.stats
        )
    }
}

private struct HistoryViewContent: View {
    let items: [HistoryListItem]
    let stats: HistoryStats?
    
    var body: some View {
        VStack {
            List(self.items) { item in
                item
                    .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .listRowBackground(Color.clear)
            .scrollContentBackground(.hidden)
            
            if let stats, stats.gamesPlayed > 0 {
                StatsView(stats: stats)
            }
        }
        .frame(width: 200)
    }
}

private struct StatsView: View {
    let stats: HistoryStats
    
    var body: some View {
        HStack {
            Text("\(self.stats.gamesPlayed) games")
            
            Spacer()
            
            Text("\(self.winRateText)")
                .foregroundStyle(self.winrate >= 50.0 ? .green : .red)
        }
        .font(.system(size: 14, weight: .semibold))
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }
    
    private var winRateText: String {
        String(format: "%.2f%%", self.winrate)
    }
    
    private var winrate: Double {
        Double(self.stats.gamesWon) / Double(self.stats.gamesPlayed) * 100
    }
}

private struct HistoryListItem: View, @preconcurrency Identifiable {
    let id: GameID
    let termination: GameTermination
    let date: Date
    let configuraiton: GameConfiguration
    let guessCount: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                self.terminationText
                    .font(.system(size: 14, weight: .semibold))
                DynamicRelativeDate(date: self.date)
                    .font(.subheadline)
            }
            
            Spacer()
            
            Text("\(self.guessCount) / \(self.configuraiton.maxGuesses)")
                .font(.system(size: 12))
            
            DifficultyIndicator(configuration: self.configuraiton)
        }
        .padding([.leading, .trailing], 4)
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
}

private struct DifficultyIndicator: View {
    let configuration: GameConfiguration
    
    var body: some View {
        Text("\(self.configuration.size)")
            .foregroundStyle(Color(white: 0.15))
            .font(.system(size: 12, weight: .bold))
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 2)
                    .fill(self.badgeColor)
            )
    }
    
    private var badgeColor: Color {
        if self.configuration.size <= 6 {
            Color.green
        }
        else if self.configuration.size <= 8 {
            Color.orange
        }
        else {
            Color.red
        }
    }
}

#Preview {
    HistoryViewContent(
        items: [
            HistoryListItem(
                id: 2,
                termination: .won,
                date: Date(timeIntervalSince1970: 1727610440),
                configuraiton: GameConfiguration(size: 6, maxGuesses: 6),
                guessCount: 4
            ),
            HistoryListItem(
                id: 1,
                termination: .lost,
                date: Date(timeIntervalSince1970: 1727610396),
                configuraiton: GameConfiguration(size: 8, maxGuesses: 6),
                guessCount: 6
            ),
            HistoryListItem(
                id: 3,
                termination: .won,
                date: Date(timeIntervalSince1970: 1727610396),
                configuraiton: GameConfiguration(size: 10, maxGuesses: 6),
                guessCount: 5
            ),
        ],
        stats: HistoryStats(
            gamesPlayed: 3,
            gamesWon: 2
        )
    )
}