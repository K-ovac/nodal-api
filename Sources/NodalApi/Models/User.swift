//
//  User.swift
//  NodalApi
//
//  Created by Максим Лозебной on 20.10.2026.
//

import Fluent
import Vapor

final class User: Model, ModelAuthenticatable, @unchecked Sendable {
    static let schema: String = "users"
    static let usernameKey: KeyPath<User, FluentKit.FieldProperty<User, String>> = \.$email
    static let passwordHashKey: KeyPath<User, FluentKit.FieldProperty<User, String>> = \.$passwordHash
    
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
    
    func toDTO() -> ResponseUserDTO {
        .init(
            username: self.username,
            email: self.email,
            avatarUrl: self.avatarUrl,
            watchlist: self.$watchlist.value?.map { $0.toDTO() } ?? []
        )
    }
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}
