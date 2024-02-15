import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "Itmo mock server"
    }

    try app.register(collection: RowController())
    try app.register(collection: AuthController())
}
