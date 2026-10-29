import Fluent
import Vapor

func routes(_ app: Application) throws {

    app.get("api", "ok") { req async -> String in
        "OK"
    }
    
    try app.register(collection: UserController())
    try app.register(collection: WatchlistCoinsController())
    try app.register(collection: MarketController())
}
