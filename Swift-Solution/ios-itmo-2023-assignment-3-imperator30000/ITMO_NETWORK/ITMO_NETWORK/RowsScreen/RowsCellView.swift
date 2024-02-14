import UIKit

struct RowsCellData: Codable {
    let id: Int
    let text: String
}

class RowsCellView: BaseTableCellView {

    private let text = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupText()
    }

    private func setupText() {
        text.numberOfLines = 0
        text.textAlignment = .natural
        contentView.addSubview(text)
        text.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            text.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            text.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -16),
            text.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant: -10),
            text.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    func configure(_ data: RowsCellData) {
        text.text = data.text
    }
}
