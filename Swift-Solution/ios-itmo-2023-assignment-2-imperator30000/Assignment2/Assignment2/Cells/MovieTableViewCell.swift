import Foundation
import Cosmos
import UIKit

class MovieTableViewCell: UITableViewCell {
    
    var onRatingChanged: ((Double) -> Void)?
    
    let ratingView: Stars = {
        let view = Stars()
        view.setupStarsView()
        view.settings.starSize = Constants.MovieTableViewCell.starsSize
        return view
    }()
    
    private let backgroundCardView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.MovieTableViewCell.backgroundСolorCard
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let movieImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.font = Constants.MovieTableViewCell.titleFilmFont
        label.textColor = Constants.MovieTableViewCell.titleFilmFontColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let directorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.font = Constants.MovieTableViewCell.directorFilmFont
        label.textColor = Constants.MovieTableViewCell.directorFilmFontColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let yearLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.MovieTableViewCell.yearFilmFont
        label.textColor = Constants.MovieTableViewCell.yearFilmFontColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let yourRatingLabel: UILabel = {
        let label = UILabel()
        label.font  = Constants.MovieTableViewCell.yourRatingFilmFont
        label.textColor = Constants.MovieTableViewCell.yourRatingFilmFontColor
        label.text = NSLocalizedString("yourMark", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        ratingView.didFinishTouchingCosmos = { [weak self] rating in
            self?.onRatingChanged(rating: rating)
        }
        
        self.backgroundColor = .clear
        self.selectionStyle = .none
        contentView.addSubview(backgroundCardView)
        
        backgroundCardView.addSubview(movieImageView)
        backgroundCardView.addSubview(titleLabel)
        backgroundCardView.addSubview(directorLabel)
        backgroundCardView.addSubview(yearLabel)
        
        backgroundCardView.addSubview(yourRatingLabel)
        backgroundCardView.addSubview(ratingView)
        
        NSLayoutConstraint.activate([
            // Constraints for backgroundCardView
            backgroundCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            backgroundCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            backgroundCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            backgroundCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            // Constraints for movieImageView
            movieImageView.leadingAnchor.constraint(equalTo: backgroundCardView.leadingAnchor, constant: 15),
            movieImageView.topAnchor.constraint(equalTo: backgroundCardView.topAnchor, constant: 15),
            movieImageView.widthAnchor.constraint(equalToConstant: 80),
            movieImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Constraints for titleLabel
            titleLabel.leadingAnchor.constraint(equalTo: movieImageView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: backgroundCardView.trailingAnchor, constant: -15),
            titleLabel.topAnchor.constraint(equalTo: backgroundCardView.topAnchor, constant: 15),
            
            // Constraints for directorLabel
            directorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            directorLabel.trailingAnchor.constraint(equalTo: backgroundCardView.trailingAnchor, constant: -15),
            directorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            
            // Constraints for yearLabel
            yearLabel.leadingAnchor.constraint(equalTo: directorLabel.leadingAnchor),
            yearLabel.topAnchor.constraint(equalTo: directorLabel.bottomAnchor, constant: 5),
            
            // Constraints for yourRatingLabel
            yourRatingLabel.leadingAnchor.constraint(equalTo: movieImageView.trailingAnchor, constant: 10),
            yourRatingLabel.topAnchor.constraint(equalTo: yearLabel.bottomAnchor, constant: 30),
            
            // Constraints for ratingView
            ratingView.leadingAnchor.constraint(equalTo: movieImageView.trailingAnchor, constant: 10),
            ratingView.topAnchor.constraint(equalTo: yourRatingLabel.bottomAnchor, constant: 5),
            
            backgroundCardView.bottomAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: 10)
        ])
    }
    
    func changeIsRatingTouched(val: Bool) {
        ratingView.isRatingTouched = val
    }
    
    func isRatingTouched() -> Bool {
        return ratingView.isRatingTouched
    }
    
    private func onRatingChanged(rating: Double) {
        ratingView.rating = rating
        changeIsRatingTouched(val: true)
        onRatingChanged?(rating)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            backgroundCardView.layer.borderWidth = 2.0
            backgroundCardView.layer.borderColor = UIColor.systemGreen.cgColor
        } else {
            backgroundCardView.layer.borderWidth = 0.0
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
