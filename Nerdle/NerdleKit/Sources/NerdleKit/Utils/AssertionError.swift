//
//  AssertionError.swift
//  NerdleKit
//
//  Created by Andrii Zinoviev on 26.09.2024.
//

struct AssertionError: Error {
    let message: String
    
    init(_ message: String) {
        assertionFailure(message)
        self.message = message
    }
}
