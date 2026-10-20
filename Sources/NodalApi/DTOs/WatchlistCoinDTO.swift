//
//  WatchlistCoinDTO.swift
//  NodalApi
//
//  Created by Максим Лозебной on 20.10.2026.
//

import Vapor

struct WatchlistCoinDTO: Content {
    var id: UUID?
    var coinId: String
}
