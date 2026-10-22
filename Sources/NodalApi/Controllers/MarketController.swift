//
//  MarketController.swift
//  NodalApi
//
//  Created by Максим Лозебной on 22.10.2026.
//

import Vapor

// MARK: - RequestConstants

private enum RequestConstants {
    static let aggName = Environment.get("DATA_AGG_NAME") ?? ""
    static let apiHeader = Environment.get("DATA_AGG_HEADER") ?? ""
    static let apiKey = Environment.get("DATA_AGG_API_KEY")
    static let baseUrl = Environment.get("DATA_AGG_URL") ?? ""
    static let expiresIn = 120  //in second
    
    enum Keys: String {
        case topList
        case globalMetrics
        case trendingCoins
        
        var endpoint: String {
            switch self {
            case .topList: return "coins/markets?vs_currency=usd"
            case .globalMetrics: return "global?vs_currency=usd"
            case .trendingCoins: return "search/trending?vs_currency=usd"
            }
        }
        
        var cacheKey: String { self.rawValue }
    }
    
    static func url(for endpoint: String) -> String {
        let endpoint = RequestConstants.Keys(rawValue: endpoint)
        
        switch endpoint {
        case .topList: return baseUrl + Keys.topList.endpoint
        case .globalMetrics: return baseUrl + Keys.globalMetrics.endpoint
        case .trendingCoins: return baseUrl + Keys.trendingCoins.endpoint
        default: return baseUrl
        }
    }
}

// MARK: - MarketController

struct MarketController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let market = routes.grouped("api", "market")
        market.get("top", use: fetchTopList)
        market.get("global", use: fetchGlobalMetrics)
        market.get("trending", use: fetchTrendingCoins)
    }
    
    // MARK: - Sendable Methods
    
    @Sendable
    func fetchTopList(req: Request) async throws -> [TokenListDTO] {
        return try await fetchAndCache(
            req: req,
            endpoint: .topList,
            responseType: [TokenListDTO].self
        )
    }
    
    @Sendable
    func fetchGlobalMetrics(req: Request) async throws -> GlobalMetricsDataDTO {
        return try await fetchAndCache(
            req: req,
            endpoint: .globalMetrics,
            responseType: GlobalMetricsDataDTO.self
        )
    }
    
    @Sendable
    func fetchTrendingCoins(req: Request) async throws -> TrendingCoinsProviderDTO {
        return try await fetchAndCache(
            req: req,
            endpoint: .trendingCoins,
            responseType: TrendingCoinsProviderDTO.self)
    }
    
    // MARK: - Private Methods
    
    private func fetchAndCache<T: Content>(
        req: Request,
        endpoint: RequestConstants.Keys,
        responseType: T.Type
    ) async throws -> T {
        let cacheKey = endpoint.cacheKey
        
        if let cachedData = try await req.cache.get(cacheKey, as: T.self) {
            req.logger.info("Get from cache: \(endpoint.cacheKey)")
            return cachedData
        }
        
        var headers = HTTPHeaders()
        if let apiKey = RequestConstants.apiKey {
            headers.add(name: RequestConstants.apiHeader, value: apiKey)
        }
        
        let url = RequestConstants.url(for: endpoint.cacheKey)
        let response = try await req.client.get(URI(string: url), headers: headers)
        
        guard response.status == .ok else {
            req.logger.error("Error from Data Agg for \(endpoint.cacheKey): \(response.status)")
            
            if response.status == .tooManyRequests {
                throw Abort(.tooManyRequests, reason: "The external API request limit has been exceeded. Please try again later.")
            }
            
            throw Abort(.internalServerError, reason: "Failed to retrieve data from the server \(RequestConstants.aggName)")
        }
        
        let decodedData = try response.content.decode(T.self)
        
        try await req.cache.set(
            cacheKey,
            to: decodedData,
            expiresIn: .seconds(RequestConstants.expiresIn)
        )
        
        req.logger.info("Data downloaded from the API and cached: \(endpoint.cacheKey)")
        return decodedData
    }
}
