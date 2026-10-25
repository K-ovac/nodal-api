//
//  AppMiddleware.swift
//  NodalApi
//
//  Created by Максим Лозебной on 25.10.2026.
//

import Vapor

struct ApiKeyMiddleware: AsyncMiddleware {
    func respond(to request: Vapor.Request, chainingTo next: any Vapor.AsyncResponder) async throws -> Vapor.Response {
        guard let expectedKey = Environment.get("APP_API_KEY") else {
            request.logger.error("Api key is not specified in the '.env' for key ")
            
            throw Abort(.internalServerError)
        }
        
        guard let providedKey = request.headers.first(name: "x-nodal-api-key"),
              providedKey == expectedKey else {
            
            throw Abort(.unauthorized, reason: "Missing or invalid API key")
        }
        
        return try await next.respond(to: request)
    }
}
