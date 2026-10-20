//
//  CreateUser.swift
//  NodalApi
//
//  Created by Максим Лозебной on 20.10.2026.
//

import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("users")
            .id()
            .field("username", .string, .required)
            .field("email", .string, .required)
            .field("avatarUrl", .string, .required)
            .field("passwordHash", .string, .required)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("users").delete()
    }
}
