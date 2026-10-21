//
//  CreateWatchlistCoin.swift
//  NodalApi
//
//  Created by Максим Лозебной on 20.10.2026.
//

import Fluent

struct CreateWatchlistCoin: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("watchlistCoins")
            .id()
            .field("coinId", .string, .required)
            .field("userId", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .unique(on: "coinId", "userId")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("watchlistCoins").delete()
    }
}
