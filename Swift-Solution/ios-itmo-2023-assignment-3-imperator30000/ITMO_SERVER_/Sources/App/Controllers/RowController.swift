import Fluent
import Vapor

struct RowController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let todos = routes.grouped("rows")
        todos.get(":page", use: index)
    }

    func index(req: Request) async throws -> [Row] {
        guard let authorization = req.headers.first(name: "authorization"), authorization == token else {
            throw Abort(.forbidden, reason: "Invalid token")
        }
        let page = req.parameters.get("page", as: Int.self) ?? 1
        let startItem = (page - 1) * 20
        let endItem = startItem + 20
        let data = rowsJson.data(using: .utf8)!
        let rows = try JSONDecoder().decode([Row].self, from: data)
        return if endItem < rows.count {
            Array(rows[startItem..<endItem])
        } else {
            []
        }
    }
}
