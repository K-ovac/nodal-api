//
//  UserController.swift
//  NodalApi
//
//  Created by Максим Лозебной on 20.10.2026.
//

import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let user = routes.grouped("user")
        
        user.get(use: self.index)
        user.post(use: self.create)
    }
    
    @Sendable
    func index(req: Request) async throws -> [UserDTO] {
        try await User.query(on: req.db)
            .with(\.$watchlist)
            .all()
            .map { $0.toDTO() }
    }
    
    @Sendable
    func create(req: Request) async throws -> UserDTO {
        let userDTO = try req.content.decode(UserDTO.self)
        let user = userDTO.toModel()
        
        if let password = userDTO.password {
            user.passwordHash = try req.password.hash(password)
        }
        
        try await user.save(on: req.db)
        
        if let watchlistDTOs = userDTO.watchlist {
            for dto in watchlistDTOs {
                let coin = WatchlistCoin(userId: try user.requireID(), coinId: dto.coinId)
                try await coin.save(on: req.db)
            }
        }
        
        // Reload to include watchlist
        return try await User.query(on: req.db)
            .filter(\.$id == user.requireID())
            .with(\.$watchlist)
            .first()
            .map { $0.toDTO() } ?? user.toDTO()
    }
}
