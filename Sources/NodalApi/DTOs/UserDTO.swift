//
//  UserDTO.swift
//  NodalApi
//
//  Created by Максим Лозебной on 20.10.2026.
//

import Fluent
import Vapor

struct CreateUserDTO: Content {
    let username: String
    let email: String
    let password: String
    let avatarUrl: String?
    
    func toModel() -> User {
        let model = User()
        
        model.username = username
        model.email = email
        model.passwordHash = password
        if let avatarUrl = self.avatarUrl {
            model.avatarUrl = avatarUrl
        }
        
        return model
    }
}

struct ResponseUserDTO: Content {
    let username: String
    let email: String
    let avatarUrl: String?
    let watchlist: [WatchlistCoinDTO]
}
