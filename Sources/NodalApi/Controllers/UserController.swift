//
//  UserController.swift
//  NodalApi
//
//  Created by Максим Лозебной on 20.10.2026.
//

import Fluent
import Vapor

// MARK: - UserController

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let user = routes.grouped("users")
        
        user.post(use: self.create)
        user.get(":username", use: self.getUser)
        
        let basicMW = User.authenticator()
        let guardMW = User.guardMiddleware()
        let protected = user.grouped(basicMW, guardMW)
        protected.get("me", use: self.getMe)
    }
    
    // MARK: - Sendable Methods
    
    @Sendable
    func getMe(_ req: Request) async throws -> ResponseUserDTO {
        let user = try req.auth.require(User.self)
        
        try await user.$watchlist.load(on: req.db)
        
        return user.toDTO()
    }
    
    @Sendable
    func getUser(_ req: Request) async throws -> ResponseUserDTO {
        guard let username = req.parameters.get("username") else {
            throw Abort(.badRequest)
        }
        
        guard let user = try await User.query(on: req.db)
            .filter(\.$username == username)
            .with(\.$watchlist)
            .first() else {
            throw Abort(.notFound)
        }
        
        return user.toDTO()
    }
    
    @Sendable
    func create(_ req: Request) async throws -> ResponseUserDTO {
        let userDTO = try req.content.decode(CreateUserDTO.self)
        let hash = try req.password.hash(userDTO.password)
        let user = User(
            username: userDTO.username,
            email: userDTO.email,
            passwordHash: hash,
            avatarUrl: userDTO.avatarUrl ?? ""
        )
        
        try await user.save(on: req.db)
        return user.toDTO()
    }
}
