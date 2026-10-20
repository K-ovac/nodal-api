//
//  UserDTO.swift
//  NodalApi
//
//  Created by Максим Лозебной on 20.10.2026.
//

import Fluent
import Vapor

struct UserDTO: Content {
    var id: UUID?
    var username: String?
    var email: String?
    var password: String?
    var avatarUrl: String?
    var watchlist: [WatchlistCoinDTO]?
    
    func toModel() -> User {
        let model = User()
        
        model.id = self.id
        if let username = self.username,
           let email = self.email,
           let avatarUrl = self.avatarUrl {
            model.username = username
            model.email = email
            model.avatarUrl = avatarUrl
        }
        
        return model
    }
}
