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
        case coinMetadata
        
        var endpoint: String {
            switch self {
            case .topList: return "coins/markets"
            case .globalMetrics: return "global"
            case .trendingCoins: return "search/trending"
            case .coinMetadata: return "coins"
            }
        }
        
        var id: String { self.rawValue }
    }
    
    static func url(for key: Keys, id: String? = nil, currency: String? = nil) -> String {
        var url = baseUrl + key.endpoint
        
        if let id = id, !id.isEmpty {
            if url.hasSuffix("/") {
                url += id
            } else {
                url += "/\(id)"
            }
        }
        
        guard let currency = currency, !currency.isEmpty else { return url }
        let separator = url.contains("?") ? "&" : "?"
        url += "\(separator)vs_currency=\(currency)"
        
        return url
    }
}

// MARK: - MarketController

struct MarketController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let market = routes.grouped("api", "market")
        market.get("top", use: self.fetchTopList)
        market.get("global", use: self.fetchGlobalMetrics)
        market.get("trending", use: self.fetchTrendingCoins)
        market.get("coin", ":id", use: self.fetchCoinMetadata)
    }
    
    // MARK: - Sendable Methods
    
    @Sendable
    func fetchTopList(req: Request) async throws -> [TokenListDTO] {
        let reqCurrency = try? req.query.get(String.self, at: "vs_currency")
        let currency = reqCurrency ?? "usd"
        
        return try await fetchAndCache(
            req: req,
            key: .topList,
            id: nil,
            currency: currency,
            responseType: [TokenListDTO].self
        )
    }
    
    @Sendable
    func fetchGlobalMetrics(req: Request) async throws -> GlobalMetricsDataDTO {
        return try await fetchAndCache(
            req: req,
            key: .globalMetrics,
            id: nil,
            currency: nil,
            responseType: GlobalMetricsDataDTO.self
        )
    }
    
    @Sendable
    func fetchTrendingCoins(req: Request) async throws -> TrendingCoinsProviderDTO {
        let reqCurrency = try? req.query.get(String.self, at: "vs_currency")
        let currency = reqCurrency ?? "usd"
        
        return try await fetchAndCache(
            req: req,
            key: .trendingCoins,
            id: nil,
            currency: currency,
            responseType: TrendingCoinsProviderDTO.self)
    }
    
    @Sendable
    func fetchCoinMetadata(req: Request) async throws -> CoinMetadataDTO {
        let reqCurrency = try? req.query.get(String.self, at: "vs_currency")
        let currency = reqCurrency ?? "usd"
        
        guard let coinId = req.parameters.get("id") else {
            throw Abort(.badRequest)
        }
        
        return try await fetchAndCache(
            req: req,
            key: .coinMetadata,
            id: coinId,
            currency: currency,
            responseType: CoinMetadataDTO.self
        )
    }
    
    // MARK: - Private Methods
    
    private func fetchAndCache<T: Content>(
        req: Request,
        key: RequestConstants.Keys,
        id: String?,
        currency: String?,
        responseType: T.Type
    ) async throws -> T {
        let currencyValue = currency != nil ? currency : ""
        let idValue = id != nil ? id : ""
        let cacheKey = "\(key.id)_" + String(describing: idValue) + "_" + String(describing: currencyValue)
        
        if let cachedData = try await req.cache.get(cacheKey, as: T.self) {
            req.logger.info("Getting from cache: \(key.id)")
            return cachedData
        }
        
        var headers = HTTPHeaders()
        headers.add(name: "Accept", value: "application/json")
        headers.add(name: "User-Agent", value: "NodalBackend/1.0")
        if let apiKey = RequestConstants.apiKey, !apiKey.isEmpty {
            headers.add(name: RequestConstants.apiHeader, value: apiKey)
        }
        
        let url = RequestConstants.url(for: key, id: id, currency: currency)
        
        req.logger.info("URL: \(url)")
        req.logger.info("Header: \(headers)")
        
        let response = try await req.client.get(URI(string: url), headers: headers)
        
        guard response.status == .ok else {
            req.logger.error("Error from Data Agg for \(key.id): \(response.status)")
            
            if response.status == .tooManyRequests {
                throw Abort(.tooManyRequests, reason: "The external API request limit has been exceeded. Please try again later.")
            }
            
            throw Abort(.internalServerError, reason: "Failed to retrieve data from the server \(RequestConstants.aggName)")
        }
        
        do {
            let decodedData = try response.content.decode(T.self)
            
            try await req.cache.set(
                cacheKey,
                to: decodedData,
                expiresIn: .seconds(RequestConstants.expiresIn)
            )
            
            req.logger.info("Data downloaded from the API and cached: \(key.id)")
            return decodedData
            
        } catch {
            req.logger.error("Error decoding JSON for \(cacheKey): \(error)")
            throw Abort(.internalServerError, reason: "Data parsing error: \(error.localizedDescription)")
        }
        
    }
}
