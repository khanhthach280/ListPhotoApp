import UIKit

class PhotoListViewController: UIViewController {
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let searchController = UISearchController(searchResultsController: nil)

    private var viewModel: PhotoListViewModel!
    private var isLoadingMore = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "List Photos"
        setupTableView()
        setupSearchController()
        bindViewModel()
        viewModel.fetchPhotos()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PhotoCell.self, forCellReuseIdentifier: PhotoCell.identifier)

        refreshControl.addTarget(self, action: #selector(refreshPhotos), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Tìm kiếm theo ID hoặc Author"
        searchController.searchBar.delegate = self // Đặt delegate
        navigationItem.searchController = searchController
        
        if let searchTextField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            searchTextField.delegate = self
        }
    }

    private func bindViewModel() {
        viewModel = PhotoListViewModel()
        viewModel.onDataUpdated = { [weak self] in
            self?.isLoadingMore = false
            self?.tableView.reloadData()
        }
    }

    @objc private func refreshPhotos() {
        viewModel.refreshPhotos()
        refreshControl.endRefreshing()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension PhotoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredPhotos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell else {
            return UITableViewCell()
        }
        cell.configure(with: viewModel.filteredPhotos[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.filteredPhotos.count - 1 && !isLoadingMore {
            isLoadingMore = true
            viewModel.loadMorePhotos()
        }
    }
}

// MARK: - UISearchResultsUpdating
extension PhotoListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.search(text: searchController.searchBar.text)
    }
}

// MARK: - UISearchBarDelegate
extension PhotoListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = searchBar.text ?? ""
        let newLength = currentText.count + text.count - range.length
        return newLength <= 15
    }
}

extension PhotoListViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*():.,<>/\\[]? ")
        return string.rangeOfCharacter(from: allowedCharacters) != nil || string.isEmpty
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*():.,<>/\\[]? ")
        let filteredText = textField.text?.filter { $0.unicodeScalars.allSatisfy { allowedCharacters.contains($0) } } ?? ""
        
        if textField.text != filteredText {
            textField.text = filteredText
        }
    }
}
