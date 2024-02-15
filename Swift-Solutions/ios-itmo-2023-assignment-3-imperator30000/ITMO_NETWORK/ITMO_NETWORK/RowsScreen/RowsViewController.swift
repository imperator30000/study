import UIKit

struct TokenContainer: Decodable {
    let token: String
}

class RowsViewController: BaseViewController<RowsView>, RowsViewDelegate {
    private var checkCollision = false
    private var lastOkPage = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        customView.delegate = self
        loadLastOkPageAndCheckCollision()
        fetchData()
    }

    func didScrollToBottom() {
        fetchData()
    }

    func loadLastOkPageAndCheckCollision() {
        lastOkPage = UserDefaults.standard.integer(forKey: "lastOkPage")
        checkCollision = UserDefaults.standard.bool(forKey: "checkCollision")
        NetworkManager.shared.setCountPage(val: lastOkPage)
    }

    private func fetchData() {
        guard var token = UserDefaults.standard.string(forKey: "authToken") else {
            return
        }
        do {
            let data = Data(token.utf8)
            let tokenContainer = try JSONDecoder().decode(TokenContainer.self, from: data)
            token = tokenContainer.token
            print("Extracted Token: \(token)")
        } catch {
            print("Error decoding token: \(error)")
        }
        NetworkManager.shared.fetchData(withToken: token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self?.handleData(data, append: true)
                case .failure(let error):
                    print("Error fetching data: \(error)")
                }
            }
        }
    }

    private func handleData(_ data: Data, append: Bool = false) {
        do {
            let newRows = try JSONDecoder().decode([RowsCellData].self, from: data)
            if newRows.isEmpty {
                checkCollision = true
                NetworkManager.shared.setCountPage(val: lastOkPage - 1)
                UserDefaults.standard.set(checkCollision, forKey: "checkCollision")
                return
            }
            if append {
                let addEmpty = customView.append(rows: newRows, checkCollision: checkCollision)
                if addEmpty {
                    NetworkManager.shared.setCountPage(val: lastOkPage - 1)
                    UserDefaults.standard.set(checkCollision, forKey: "checkCollision")
                    return
                }
            } else {
                customView.set(rows: newRows)
            }
            lastOkPage += 1
            checkCollision = false

            UserDefaults.standard.set(lastOkPage, forKey: "lastOkPage")
            UserDefaults.standard.set(checkCollision, forKey: "checkCollision")
        } catch {
            print("Error parsing data: \(error)")
        }
    }
}

protocol RowsViewDelegate: AnyObject {
    func didScrollToBottom()
}
