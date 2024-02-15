import UIKit

class RowsView: BaseView {
    private let tableView = UITableView()
    private var rows: [RowsCellData] = []
    weak var delegate: RowsViewDelegate?

    required init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        tableSetup()
        loadCachedRows()
    }

    func append(rows: [RowsCellData], checkCollision: Bool) -> Bool {
        var startInd = 0
        if checkCollision {
            let rowsLen = rows.count
            let selfRowsLen = self.rows.count

            for i in 0...(rowsLen - 1) {
                if rows[i].id != self.rows[selfRowsLen - rowsLen + i].id {
                    startInd = i
                    break
                }
            }
            if startInd == 0 {
                return true
            }
        }
        self.rows.append(contentsOf: rows[startInd...])
        tableView.reloadData()
        cacheRows()
        return false
    }

    private func tableSetup() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 50
        tableView.register(RowsCellView.self, forCellReuseIdentifier: RowsCellView.identifier)
        tableView.allowsSelection = false

        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
        ])
    }

    func set(rows: [RowsCellData]) {
        self.rows = rows
        tableView.reloadData()
        cacheRows()
    }

    func cacheRows() {
        let encoder = JSONEncoder()
        if let encodedRows = try? encoder.encode(rows) {
            UserDefaults.standard.set(encodedRows, forKey: "cachedRows")
        }
    }

    func loadCachedRows() {
        if let cachedRows = UserDefaults.standard.data(forKey: "cachedRows") {
            let decoder = JSONDecoder()
            if let loadedRows = try? decoder.decode([RowsCellData].self, from: cachedRows) {
                self.rows = loadedRows
            }
        }
    }
}

extension RowsView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RowsCellView.identifier, for: indexPath) as? RowsCellView else {
            return UITableViewCell()
        }
        let row = rows[indexPath.row]
        cell.configure(row)

        return cell
    }
}

extension RowsView: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let tableViewContentSizeHeight = tableView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height

        if position > (tableViewContentSizeHeight - 100 - scrollViewHeight) {
            delegate?.didScrollToBottom()
        }
    }
}
