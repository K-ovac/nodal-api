//
//  User.swift
//  NodalApi
//
//  Created by Максим Лозебной on 20.10.2026.
//

import Fluent
import Vapor
import struct Foundation.UUID

final class User: Model, @unchecked Sendable {
    static let schema: String = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "passwordHash")
    var passwordHash: String
    
    @Field(key: "avatarUrl")
    var avatarUrl: String
    
    @Children(for: \.$user)
    var watchlist: [WatchlistCoin]
    
    init() {}
    
    init(
        id: UUID? = nil,
        username: String,
        email: String,
        passwordHash: String,
        avatarUrl: String
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.passwordHash = passwordHash
        self.avatarUrl = avatarUrl
    }
    
    func toDTO() -> UserDTO {
        .init(
            id: self.id,
            username: self.username,
            email: self.email,
            password: self.passwordHash,
            avatarUrl: self.avatarUrl,
            watchlist: self.$watchlist.value?.map { $0.toDTO() }
        )
    }
}
