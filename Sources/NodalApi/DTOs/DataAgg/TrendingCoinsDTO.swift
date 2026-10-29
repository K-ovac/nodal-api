//
//  TrendingCoinsDTO.swift
//  NodalApi
//
//  Created by Максим Лозебной on 29.10.2026.
//

import Vapor

// MARK:  Trending Coins

struct TrendingCoinsProviderDTO: Content {
    let coins: [TrendingCoinItemDTO]
}

struct TrendingCoinItemDTO: Content {
    let item: TrendingCoinDTO
}

struct TrendingCoinDTO: Content {
    let id: String
    let name: String
    let symbol: String
    let market_cap_rank: Int
    let thumb: String
    let small: String
    let large: String
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
