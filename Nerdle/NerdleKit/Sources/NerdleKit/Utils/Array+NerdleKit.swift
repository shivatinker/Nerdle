//
//  Array+NerdleKit.swift
//  Nerdle
//

extension Array {
    public subscript(safe index: Int) -> Element? {
        guard index >= self.startIndex, index < self.endIndex else {
            return nil
        }
        
        return self[index]
    }
}
