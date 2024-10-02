//
//  Optional+NerdleKit.swift
//  NerdleKit
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
