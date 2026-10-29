//
//  GlobalMetricsDTO.swift
//  NodalApi
//
//  Created by Максим Лозебной on 29.10.2026.
//

import Vapor

// MARK: - Global Metrics Data

struct GlobalMetricsDataDTO: Content {
    let data: GlobalMetricsDTO
}

struct GlobalMetricsDTO: Content {
    let active_cryptocurrencies: Int
    let market_cap_percentage: MarketCapPercentage
    let market_cap_change_percentage_24h_usd: Double?
    let total_market_cap: MarketCapValue
    let total_volume: MarketCapValue
}

struct MarketCapValue: Content {
    let btc: Double?
    let usd: Double?
    let eur: Double?
    let rub: Double?
    let cny: Double?
}

struct MarketCapPercentage: Content {
    let btc: Double?
    let eth: Double?
    let usdt: Double?
    let sol: Double?
    let bnb: Double?
}
