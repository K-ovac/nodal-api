//
//  DataAggDTO.swift
//  NodalApi
//
//  Created by Максим Лозебной on 22.10.2026.
//


import Vapor

// MARK: - Token List

struct TokenListDTO: Content {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let current_price: Double
    let market_cap: Double
    let market_cap_rank: Int
    let price_change_percentage_24h: Double?
}

// MARK: - Global Metrics Data

struct GlobalMetricsDataDTO: Content {
    let data: GlobalMetricsDTO
}

struct GlobalMetricsDTO: Content {
    let active_cryptocurrencies: Int
    let market_cap_percentage: MarketCapPercentage
    let market_cap_change_percentage_24h_usd: Double?
}

struct MarketCapPercentage: Content {
    let btc: Double?
    let eth: Double?
    let usdt: Double?
}

// MARK: - Coin Metadata

struct CoinMetadataDTO: Content {
    let id: String
    let name: String
    let symbol: String
    let description: CoinDescriptionDTO
    let image: CoinImageDTO
    let market_data: CoinMarketDataDTO
    let links: CoinLinksDTO
}

struct CoinDescriptionDTO: Content {
    let en: String
    let ru: String
    let zh: String
}

struct CoinImageDTO: Content {
    let small: String
}

struct CoinMarketDataDTO: Content {
    let current_price: CoinCurrentPrice
    let market_cap_rank: Int
    let price_change_percentage_24h: Double?
    let fully_diluted_valuation: CoinCurrentPrice
    let market_cap: CoinCurrentPrice
    let total_volume: CoinCurrentPrice
    let circulating_supply: Double
    let total_supply: Double
    let max_supply: Int?
    let high_24h: CoinCurrentPrice
    let low_24h: CoinCurrentPrice
}

struct CoinCurrentPrice: Content {
    let btc: Double
    let usd: Double
    let eur: Double
    let rub: Double
    let cny: Double
}

struct CoinLinksDTO: Content {
    let homepage: [String]
    let whitepaper: String
    let repos_url: CoinReposUrl
    let twitter_screen_name: String
}

struct CoinReposUrl: Content {
    let github: [String]
}

// MARK:  Trending Coins

struct TrendingCoinsProviderDTO: Content {
    let coins: [TrendingCoinItemDTO]
}

struct TrendingCoinItemDTO: Content {
    let item: TrendingCoinDTO
}

struct TrendingCoinDTO: Content {
    let id: String
    let symbol: String
    let small: String
    let data: TrendingCoinDataDTO
}

struct TrendingCoinDataDTO: Content {
    let price: Double
    let price_change_percentage_24h: TrendingCoinPriceChangePercentage24hDTO
}

struct TrendingCoinPriceChangePercentage24hDTO: Content {
    let btc: Double?
    let usd: Double?
    let eur: Double?
    let rub: Double?
    let cny: Double?
}
