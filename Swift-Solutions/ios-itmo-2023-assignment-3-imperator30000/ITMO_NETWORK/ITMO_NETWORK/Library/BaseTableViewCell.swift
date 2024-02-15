import UIKit

class BaseTableCellView: UITableViewCell {

    static var identifier: String { String(describing: Self.self) }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    @available(*, unavailable, message: "use init(style:reuseIdentifier:) insted")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

