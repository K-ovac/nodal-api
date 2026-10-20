//
//  WatchlistCoin.swift
//  NodalApi
//
//  Created by Максим Лозебной on 20.10.2026.
//

import Fluent
import struct Foundation.UUID

final class WatchlistCoin: Model, @unchecked Sendable {
    static let schema: String = "watchlistCoins"
    
    @Parent(key: "userId")
    var user: User
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "coinId")
    var coinId: String
    
    init() { }
    
    init(
        userId: User.IDValue,
        id: UUID? = nil,
        coinId: String
    ) {
        self.$user.id = userId
        self.id = id
        self.coinId = coinId
    }
    
    func toDTO() -> WatchlistCoinDTO {
        .init(
            id: self.id,
            coinId: self.coinId
        )
    }
}
