//
//  Array+Nerdle.swift
//  Nerdle
//
//  Created by Andrii Zinoviev on 27.09.2024.
//

extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= self.startIndex, index < self.endIndex else {
            return nil
        }
        
        return self[index]
    }
}
