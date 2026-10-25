//
//  Untitled.swift
//  NodalApi
//
//  Created by Максим Лозебной on 21.10.2026.
//

import Fluent
import Vapor

// MARK: - WatchlistCoinsController

struct WatchlistCoinsController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let protectedRoutes = routes.grouped(ApiKeyMiddleware())
        let watchlistCoins = protectedRoutes.grouped("watchlist")
        let basicMW = User.authenticator()
        let guardMW = User.guardMiddleware()
        let protected = watchlistCoins.grouped(basicMW, guardMW)
        
        protected.post(":coinId", use: self.addToWatchlist)
        protected.delete(":coinId", use: self.removeFromWatchlist)
    }
    
    // MARK: - Sendable Methods
    
    @Sendable
    func addToWatchlist(_ req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        let userId = try user.requireID()
        
        guard let coinId = req.parameters.get("coinId") else {
            throw Abort(.badRequest)
        }
        
        let exists = try await WatchlistCoin.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$coinId == coinId)
            .first()
        
        if exists == nil {
            let newItem = WatchlistCoin(
                userId: userId,
                coinId: coinId
            )
            
            try await newItem.save(on: req.db)
        }
        
        return .ok
    }
    
    @Sendable
    func removeFromWatchlist(_ req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        let userId = try user.requireID()
        
        guard let coinId = req.parameters.get("coinId") else {
            throw Abort(.badRequest)
        }
        
        try await WatchlistCoin.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$coinId == coinId)
            .delete()
        
        return .noContent
    }
}
