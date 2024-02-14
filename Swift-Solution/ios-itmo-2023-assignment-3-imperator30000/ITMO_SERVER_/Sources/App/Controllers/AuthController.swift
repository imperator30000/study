import Fluent
import Vapor

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let todos = routes.grouped("auth")
        todos.post("login", use: index)
    }

    func index(req: Request) async throws -> LoginResponse {
        let payload = try req.content.decode(LoginPayload.self)
        return if payload.email == "johndown@exmample.com" && payload.password == "1234567" {
            LoginResponse(token: token)
        } else {
            throw Abort(.unauthorized, reason: "Invalid Credentials")
        }
    }
}

let token = "uO3tFMM8I7B1T7kHcDgrRZaYJHVafja3"

struct LoginPayload: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Content {
    let token: String
}
