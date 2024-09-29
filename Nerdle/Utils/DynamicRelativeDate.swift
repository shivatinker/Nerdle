//
//  DynamicRelativeDate.swift
//  Nerdle
//
//  Created by Andrii Zinoviev on 29.09.2024.
//

import SwiftUI

struct DynamicRelativeDate: View {
    @StateObject private var dateUpdater: DateUpdater = .global
    
    let date: Date
    
    var body: some View {
        Text(self.dateUpdater.relativeString(for: self.date))
    }
}

private final class DateUpdater: ObservableObject {
    @MainActor static let global = DateUpdater()
    
    let objectWillChange = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    func relativeString(for date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: date, relativeTo: .now)
    }
}
