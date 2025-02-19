import UIKit

class ViewController: UIViewController {
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private var photos: [Photo] = []
    private var filteredPhotos: [Photo] = []
    private var currentPage = 1
    private var isLoading = false
    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "List Photos"
        
        setupTableView()
        setupSearchController()
        fetchPhotos()
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
        tableView.register(PhotoCell.self, forCellReuseIdentifier: "PhotoCell")

        // Pull to Refresh
        refreshControl.addTarget(self, action: #selector(refreshPhotos), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Tìm kiếm theo ID hoặc Author"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    @objc private func refreshPhotos() {
        currentPage = 1
        fetchPhotos()
    }

    private func fetchPhotos(loadMore: Bool = false) {
        if isLoading { return }
        isLoading = true

        APIService.shared.fetchPhotos(page: currentPage) { [weak self] newPhotos in
            guard let self = self, let newPhotos = newPhotos else { return }

            if loadMore {
                self.photos.append(contentsOf: newPhotos)
            } else {
                self.photos = newPhotos
            }

            self.filteredPhotos = self.photos // Cập nhật danh sách lọc

            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            self.isLoading = false
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPhotos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as? PhotoCell else {
            return UITableViewCell()
        }
        cell.configure(with: filteredPhotos[indexPath.row])
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        if offsetY > contentHeight - frameHeight * 1.5 {
            if !isLoading {
                currentPage += 1
                fetchPhotos(loadMore: true)
            }
        }
    }
}

// MARK: - UISearchResultsUpdating & UISearchBarDelegate
extension ViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased(), !searchText.isEmpty else {
            filteredPhotos = photos
            tableView.reloadData()
            return
        }

        filteredPhotos = photos.filter { photo in
            return photo.id.contains(searchText) || photo.author.lowercased().contains(searchText)
        }

        tableView.reloadData()
    }
}
