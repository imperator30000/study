import UIKit

class ViewController: UIViewController {
    private var movies: [Movie] = []
    private var tableView = UITableView()
    private var lastIndexCell: IndexPath?
    
    var headerLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("movieListTitle", comment: "")
        titleLabel.font = Constants.headersFont
        titleLabel.textColor = Constants.headersColor
        titleLabel.sizeToFit()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    enum SortType {
        case date
        case rating
    }
    
    private var currentSortType: SortType = .date
    
    let backItem = UIBarButtonItem(title: NSLocalizedString("backButton", comment: ""), style: .plain, target: nil, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        view.backgroundColor = Constants.ViewController.backgroundColor
        tableView.delegate = self
        
        setupUI()
    }
    
    private func setupUI() {
        setupNavigationBar()
        setupTableView()
        addSampleMovies()
        sortMovies()
    }
    
    private func setupNavigationBar() {
        setupBackItem()
        setupAddButton()
        setupSortButtons()
        setupHeaderLabel()
    }
    
    private func setupBackItem() {
        navigationItem.backBarButtonItem = backItem
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    private func setupSortButtons() {
        let sortByDateButton = UIBarButtonItem(title: NSLocalizedString("sortByDate", comment: ""), style: .plain, target: self, action: #selector(sortByDateTapped))
        let sortByRatingButton = UIBarButtonItem(title: NSLocalizedString("sortByRating", comment: ""), style: .plain, target: self, action: #selector(sortByRatingTapped))
        updateSortButtonStyles(dateButton: sortByDateButton, ratingButton: sortByRatingButton)
        
        navigationItem.leftBarButtonItems = [sortByDateButton, sortByRatingButton]
    }
    
    @objc private func sortByDateTapped() {
        currentSortType = .date
        sortMovies()
    }
    
    @objc private func sortByRatingTapped() {
        currentSortType = .rating
        sortMovies()
    }
    
    private func sortButtonMakeGray() {
        if currentSortType == .date {
            return
        }
        
        if let dateButton = navigationItem.leftBarButtonItems?[0], let ratingButton = navigationItem.leftBarButtonItems?[1] {
            ratingButton.tintColor = Constants.ViewController.navigationBarSecondColor
            dateButton.tintColor = Constants.ViewController.navigationBarSecondColor
        }
    }
    
    private func sortMovies() {
        if let dateButton = navigationItem.leftBarButtonItems?[0], let ratingButton = navigationItem.leftBarButtonItems?[1] {
            updateSortButtonStyles(dateButton: dateButton, ratingButton: ratingButton)
        }
        
        switch currentSortType {
        case .date:
            movies.sort(by: { $0.year < $1.year })
        case .rating:
            movies.sort(by: { $0.rating > $1.rating })
        }
        tableView.reloadData()
    }
    
    private func addSampleMovies() {
        let inception = Movie(title: "Начало", director: "Кристофер Нолан", year: 2010, rating: 1.0, image: UIImage(named: "inception") ?? UIImage())
        let interstellar = Movie(title: "Интерстеллар", director: "Кристофер Нолан", year: 2014, rating: 2.0, image: UIImage(named: "interstellar") ?? UIImage())
        let matrix = Movie(title: "Матрица", director: "Лана Вачовски, Лилли Вачовски", year: 1999, rating: 3.0, image: UIImage(named: "matrix") ?? UIImage())
        let shawshank = Movie(title: "Побег из Шоушенка", director: "Фрэнк Дарабонт", year: 1994, rating: 4.0, image: UIImage(named: "shawshank") ?? UIImage())
        let godfather = Movie(title: "Крестный отец", director: "Фрэнсис Форд Коппола", year: 1972, rating: 5.0, image: UIImage(named: "godfather") ?? UIImage())
        
        movies.append(contentsOf: [inception, interstellar, matrix, shawshank, godfather])
        sortMovies()
    }
    
    private func setupHeaderLabel() {
        view.addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 10),
            headerLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10)
        ])
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: "MovieCell")
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupAddButton() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func updateSortButtonStyles(dateButton: UIBarButtonItem, ratingButton: UIBarButtonItem) {
        let selectedColor = UINavigationBar.appearance().tintColor
        switch currentSortType {
        case .date:
            dateButton.tintColor = selectedColor
            ratingButton.tintColor = Constants.ViewController.navigationBarSecondColor
        case .rating:
            dateButton.tintColor = Constants.ViewController.navigationBarSecondColor
            ratingButton.tintColor = selectedColor
        }
    }
    
    internal func didTapAddMovieButton(movie: Movie) {
        movies.append(movie)
        sortMovies()
        tableView.reloadData()
    }
    
    internal func didUpdateMovie(movie: Movie, at index: Int) {
        movies[index] = movie
        sortMovies()
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieTableViewCell
        let movie = movies[indexPath.row]
        cell.movieImageView.image = movie.image
        cell.titleLabel.text = movie.title
        cell.directorLabel.text = movie.director
        cell.yearLabel.text = "\(movie.year)"
        cell.ratingView.setRating(newRating: movie.rating)
        cell.onRatingChanged = { [weak self] newRating in
            self?.movies[indexPath.row].rating = newRating
        }
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cardTapped(indexPath: indexPath)
    }
    
    func cardTapped(indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MovieTableViewCell
        if cell.isRatingTouched() {
            tableView.deselectRow(at: indexPath, animated: false)
            sortMovies()
        } else {
            let movie = movies[indexPath.row]
            let addMovieVC = AddMovieViewController()
            addMovieVC.selectedMovie = movie
            addMovieVC.delegate = self
            addMovieVC.selectedMovieIndex = indexPath.row
            navigationController?.pushViewController(addMovieVC, animated: true)
        }
        cell.changeIsRatingTouched(val: false)
    }
}

extension ViewController: AddMovieViewControllerDelegate {
    @objc private func addButtonTapped() {
        let addMovieVC = AddMovieViewController()
        addMovieVC.delegate = self
        navigationController?.pushViewController(addMovieVC, animated: true)
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            handleScrollEnd()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        handleScrollEnd()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let touchPoint = scrollView.panGestureRecognizer.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: touchPoint) {
            lastIndexCell = indexPath
        }
    }
    
    private func handleScrollEnd() {
        if let validIndexPath = lastIndexCell,
           let cell = tableView.cellForRow(at: validIndexPath) as? MovieTableViewCell,
           cell.isRatingTouched() {
            cell.changeIsRatingTouched(val: false)
        }
    }
}
