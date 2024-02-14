import UIKit

class BaseView: UIView {
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
    }

    @available(*, unavailable, message: "use init(frame:) insted")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
