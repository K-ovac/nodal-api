//
//  CoinMetadataDTO.swift
//  NodalApi
//
//  Created by Максим Лозебной on 29.10.2026.
//

import Vapor

// MARK: - Coin Metadata

struct CoinMetadataDTO: Content {
    let id: String
    let name: String
    let symbol: String
    let description: CoinDescriptionDTO
    let image: CoinImageDTO
    let market_data: CoinMarketDataDTO
    let links: CoinLinksDTO
    let categories: [String]
}

struct CoinDescriptionDTO: Content {
    let en: String
    let ru: String
    let zh: String
    let fr: String
}

struct CoinImageDTO: Content {
    let thumb: String
    let small: String
    let large: String
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
    let ath: CoinCurrentPrice
    let ath_change_percentage: CoinCurrentPrice
    let ath_date: CoinCurrentDate
    let atl: CoinCurrentPrice
    let atl_change_percentage: CoinCurrentPrice
    let atl_date: CoinCurrentDate
    let price_change_24h: Double?
    let price_change_percentage_7d: Double?
    let price_change_percentage_14d: Double?
    let price_change_percentage_30d: Double?
    let price_change_percentage_60d: Double?
    let price_change_percentage_200d: Double?
    let price_change_percentage_1y: Double?
    let market_cap_change_24h: Double?
    let market_cap_change_percentage_24h: Double?
}

struct CoinCurrentPrice: Content {
    let btc: Double
    let usd: Double
    let eur: Double
    let rub: Double
    let cny: Double
}

struct CoinCurrentDate: Content {
    let btc: String
    let usd: String
    let eur: String
    let rub: String
    let cny: String
}

struct CoinLinksDTO: Content {
    let homepage: [String]
    let whitepaper: String
    let blockchain_site: [String]
    let official_forum_url: [String]
    let chat_url: [String]
    let announcement_url: [String]
    let twitter_screen_name: String
    let repos_url: CoinReposUrl
}

struct CoinReposUrl: Content {
    let github: [String]
    let bitbucket: [String]
}
