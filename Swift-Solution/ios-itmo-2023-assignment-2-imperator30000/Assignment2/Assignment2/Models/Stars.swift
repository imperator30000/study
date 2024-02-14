import Foundation
import Cosmos

class Stars: CosmosView {
    private var oldRating: Double?
    var isRatingTouched = false

    private func touch() {
        if let oldRatingValid = oldRating, oldRatingValid == rating {
            rating -= 1
        }
        oldRating = rating
    }

    func setRating(newRating: Double) {
        rating = newRating
        oldRating = rating
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touch()
    }

    func setupStarsView() {
        settings.fillMode = .full
        settings.updateOnTouch = true
        rating = 0
        settings.minTouchRating = 0.0
        settings.emptyColor = Constants.backgroundStarsColor
        settings.emptyBorderColor = Constants.backgroundStarsColor
        settings.filledColor = Constants.StarsColor
        translatesAutoresizingMaskIntoConstraints = false
        oldRating = rating
    }
}
