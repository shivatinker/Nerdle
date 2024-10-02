//
//  DatabaseController.swift
//  NerdleKit
//
//  Created by Andrii Zinoviev on 29.09.2024.
//

import Combine
import GRDB

public final class DatabaseController {
    private let queue: DatabaseQueue
    
    public init(path: String?) throws {
        if let path {
            self.queue = try DatabaseQueue(path: path)
        }
        else {
            self.queue = try DatabaseQueue()
        }
        
        let migrator = self.makeMigrator()
        try migrator.migrate(self.queue)
    }
    
    public func read<T>(_ body: (GameDatabase) throws -> T) throws -> T {
        try self.queue.read { db in
            try body(GameDatabase(db))
        }
    }

    public func write<T>(_ updates: (GameDatabase) throws -> T) throws -> T {
        try self.queue.write { db in
            try updates(GameDatabase(db))
        }
    }
    
    public func observe<T>(_ body: @escaping (GameDatabase) throws -> T) -> some Publisher<T, Error> {
        ValueObservation
            .tracking { db in
                try body(GameDatabase(db))
            }
            .publisher(in: self.queue, scheduling: .immediate)
    }
    
    // MARK: Migrations
    
    private func makeMigrator() -> DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("v1.0") { db in
            try db.create(table: "game_history") { table in
                table.autoIncrementedPrimaryKey("id")
                table.column("date", .datetime).notNull()
                table.column("state", .jsonText).notNull()
                table.column("termination", .text).notNull()
            }
        }
        
        migrator.registerMigration("v1,1") { db in
            try db.alter(table: "game_history") { table in
                table.add(column: "dailyGameDate", .text)
            }
        }
        
        return migrator
    }
}
