import UIKit

class BaseViewController<View>: UIViewController where View: BaseView {

    let customView = View(frame: .zero)

    override func loadView() {
        view = customView
    }

}
