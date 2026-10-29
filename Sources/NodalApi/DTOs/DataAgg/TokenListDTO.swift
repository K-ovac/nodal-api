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
