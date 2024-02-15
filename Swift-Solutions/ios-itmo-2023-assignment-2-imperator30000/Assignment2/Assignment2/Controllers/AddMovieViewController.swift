import UIKit
import Cosmos
import TinyConstraints

class AddMovieViewController: UIViewController, UITextFieldDelegate {
    private var saveButtonBottomConstraint: NSLayoutConstraint?
    private var yourRatingBottomAnchorConstraint: NSLayoutConstraint?
    private let yourRatingBottomAnchorConstraintWithOutKeyboardConst: CGFloat = -50
    private var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    private var containerView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    private var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("title", comment: "")
        titleLabel.textColor = Constants.AddMovieViewController.titleFilmFontColor
        titleLabel.font = Constants.AddMovieViewController.titleFilmFont
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    private var titleTextField: UITextField = {
        let field = UITextField()
        field.placeholder = NSLocalizedString("titlePlaceholder", comment: "")
        field.borderStyle = .roundedRect
        field.backgroundColor = Constants.AddMovieViewController.fieldTitleFilmFontColor
        field.font = Constants.AddMovieViewController.fieldTitleFilmFont
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private var directorLabel: UILabel = {
        let directorLabel = UILabel()
        directorLabel.text = NSLocalizedString("director", comment: "")
        directorLabel.textColor = Constants.AddMovieViewController.directorFilmFontColor
        directorLabel.font = Constants.AddMovieViewController.directorFilmFont
        directorLabel.translatesAutoresizingMaskIntoConstraints = false
        return directorLabel
    }()
    
    private var directorTextField: UITextField = {
        let directorTextField = UITextField()
        directorTextField.placeholder = NSLocalizedString("directorPlaceholder", comment: "")
        directorTextField.borderStyle = .roundedRect
        directorTextField.backgroundColor = Constants.AddMovieViewController.fieldDirectorFilmFontColor
        directorTextField.font = Constants.AddMovieViewController.fieldDirectorFilmFont
        directorTextField.translatesAutoresizingMaskIntoConstraints = false
        return directorTextField
    }()
    
    private var yearLabel: UILabel = {
        let yearLabel = UILabel()
        yearLabel.text = NSLocalizedString("year", comment: "")
        yearLabel.textColor = Constants.AddMovieViewController.yearFilmFontColor
        yearLabel.font = Constants.AddMovieViewController.yearFilmFont
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        return yearLabel
    }()
    
    private var yearTextField: UITextField = {
        let yearTextField = UITextField()
        yearTextField.placeholder = NSLocalizedString("yearPlaceholder", comment: "")
        yearTextField.borderStyle = .roundedRect
        yearTextField.keyboardType = .numberPad
        yearTextField.backgroundColor = Constants.AddMovieViewController.fieldYearFilmFontColor
        yearTextField.font = Constants.AddMovieViewController.fieldYearFilmFont
        yearTextField.translatesAutoresizingMaskIntoConstraints = false
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: NSLocalizedString("return", comment: ""), style: .done, target: yearTextField, action: #selector(yearTextField.resignFirstResponder))
        toolbar.setItems([flexSpace, doneButton], animated: false)
        toolbar.tintColor = Constants.mainColor
        yearTextField.inputAccessoryView = toolbar
        return yearTextField
    }()
    
    private var yourRating: UILabel = {
        let yourRating = UILabel()
        yourRating.text = NSLocalizedString("yourMark", comment: "")
        yourRating.textColor = Constants.AddMovieViewController.yourRatingFilmFontColor
        yourRating.font = Constants.AddMovieViewController.yourRatingFilmFont
        yourRating.translatesAutoresizingMaskIntoConstraints = false
        return yourRating
    }()
    
    private let ratingView: Stars = {
        let view = Stars()
        view.setupStarsView()
        view.settings.starSize = Constants.AddMovieViewController.starsSize
        return view
    }()
    
    private var saveButton: UIButton = {
        let saveButton = UIButton()
        saveButton.setTitle(NSLocalizedString("save", comment: ""), for: .normal)
        saveButton.backgroundColor = Constants.mainColor
        saveButton.layer.cornerRadius = 20
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        return saveButton
    }()
    
    private let headerLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("movie", comment: "")
        titleLabel.font = Constants.headersFont
        titleLabel.textColor = Constants.headersColor
        return titleLabel
    }()
    
    private let noPhoto: UIImage = {
        guard let image = UIImage(named: "noPhoto.png") else {
            fatalError("Default image not found!")
        }
        return image
    }()
    
    var selectedMovie: Movie?
    var selectedMovieIndex: Int?
    
    weak var delegate: AddMovieViewControllerDelegate?
    
    private func updateUIWithMovieData() {
        guard let movie = selectedMovie else { return }
        titleTextField.text = movie.title
        directorTextField.text = movie.director
        yearTextField.text = "\(movie.year)"
        ratingView.setRating(newRating: movie.rating)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUIWithMovieData()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.AddMovieViewController.backgroundСolor
        navigationItem.titleView = headerLabel
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setupUI()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3) {
                self.saveButtonBottomConstraint?.constant = -keyboardSize.height
                self.yourRatingBottomAnchorConstraint?.constant = self.yourRatingBottomAnchorConstraintWithOutKeyboardConst - keyboardSize.height
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.saveButtonBottomConstraint?.constant = -10
            self.yourRatingBottomAnchorConstraint?.constant = self.yourRatingBottomAnchorConstraintWithOutKeyboardConst
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func checkFieldsAndRating() {
        if let title = titleTextField.text,
           let director = directorTextField.text,
           let year = yearTextField.text,
           let yearInt = Int(year),
           yearInt >= 1895 && yearInt <= Calendar.current.component(.year, from: Date()),
           0 <= title.count && title.count <= 200 && 0 < director.count && director.count <= 200 {
            saveButton.alpha = 1.0
            saveButton.isUserInteractionEnabled = true
        } else {
            saveButton.alpha = 0.7
            saveButton.isUserInteractionEnabled = false
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkFieldsAndRating()
    }
    
    @objc func saveButtonTapped() {
        if let title = titleTextField.text,
           let director = directorTextField.text,
           let year = yearTextField.text,
           let yearInt = Int(year) {
            let updatedMovie = Movie(title: title, director: director, year: yearInt, rating: ratingView.rating, image: selectedMovie?.image ?? noPhoto)
            if let index = selectedMovieIndex {
                delegate?.didUpdateMovie(movie: updatedMovie, at: index)
            } else {
                delegate?.didTapAddMovieButton(movie: updatedMovie)
            }
        } else {
            return
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func starsTapped() {
        self.checkFieldsAndRating()
    }
    
    private func setupUI() {
        ratingView.didFinishTouchingCosmos = { [weak self] _ in
            self?.starsTapped()
        }
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(titleTextField)
        containerView.addSubview(directorLabel)
        containerView.addSubview(directorTextField)
        containerView.addSubview(yearLabel)
        containerView.addSubview(yearTextField)
        containerView.addSubview(ratingView)
        containerView.addSubview(yourRating)
        view.addSubview(saveButton)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        saveButtonBottomConstraint = saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        yourRatingBottomAnchorConstraint = yourRating.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: yourRatingBottomAnchorConstraintWithOutKeyboardConst)
        
        NSLayoutConstraint.activate([
            // Constraints for scrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            // Constraints for containerView
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Constraints for titleLabel
            titleLabel.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            
            // Constraints for titleTextField
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            titleTextField.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 40),
            
            // Constraints for directorLabel
            directorLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            directorLabel.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            
            // Constraints for directorTextField
            directorTextField.topAnchor.constraint(equalTo: directorLabel.bottomAnchor, constant: 5),
            directorTextField.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            directorTextField.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            directorTextField.heightAnchor.constraint(equalToConstant: 40),
            
            // Constraints for yearLabel
            yearLabel.topAnchor.constraint(equalTo: directorTextField.bottomAnchor, constant: 20),
            yearLabel.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            
            // Constraints for yearTextField
            yearTextField.topAnchor.constraint(equalTo: yearLabel.bottomAnchor, constant: 5),
            yearTextField.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            yearTextField.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            yearTextField.heightAnchor.constraint(equalToConstant: 40),
            
            // Constraints for ratingView
            ratingView.topAnchor.constraint(equalTo: yearTextField.bottomAnchor, constant: 40),
            ratingView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            // Constraints for yourRating
            yourRating.topAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: 10),
            yourRating.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            // Constraints for saveButton
            saveButton.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        saveButtonBottomConstraint?.isActive = true
        yourRatingBottomAnchorConstraint?.isActive = true
        titleTextField.delegate = self
        directorTextField.delegate = self
        yearTextField.delegate = self
        
        checkFieldsAndRating()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

protocol AddMovieViewControllerDelegate: AnyObject {
    func didTapAddMovieButton(movie: Movie)
    func didUpdateMovie(movie: Movie, at index: Int)
}
