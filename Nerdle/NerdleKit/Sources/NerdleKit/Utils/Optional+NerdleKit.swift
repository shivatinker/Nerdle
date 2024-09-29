//
//  Optional+NerdleKit.swift
//  NerdleKit
//
//  Created by Andrii Zinoviev on 29.09.2024.
//

extension Optional {
    enum Error: Swift.Error {
        case unexpectedNil
    }

    func unwrap() throws -> Wrapped {
        guard let self else {
            throw Error.unexpectedNil
        }
        
        return self
    }
}
