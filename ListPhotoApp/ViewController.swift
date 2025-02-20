import UIKit

class ViewController: UIViewController {
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private var photos: [Photo] = []
    private var filteredPhotos: [Photo] = []
    private var currentPage = 1
    private var isLoading = false
    private var isSearching = false // Thêm biến kiểm tra trạng thái tìm kiếm
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

    // MARK: - Loại bỏ dấu tiếng Việt
    func removeDiacritics(from text: String) -> String {
        return text.folding(options: .diacriticInsensitive, locale: .current)
    }

    // MARK: - Loại bỏ ký tự đặc biệt & emoji, chỉ giữ lại ký tự hợp lệ
    func filterValidCharacters(from text: String) -> String {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*():.,<>/\\[]? ")
        return text.unicodeScalars.filter { allowedCharacters.contains($0) }.map { String($0) }.joined()
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

        // Không gọi API nếu đang tìm kiếm
        if isSearching { return }

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
        guard let searchText = searchController.searchBar.text else {
            filteredPhotos = photos
            tableView.reloadData()
            return
        }

        // Kiểm tra trạng thái tìm kiếm
        isSearching = !searchText.isEmpty

        // Giới hạn độ dài tối đa là 15 ký tự
        var trimmedSearchText = String(searchText.prefix(15))

        // Nếu nhập quá 15 ký tự, tự động cắt bớt
        if searchText.count > 15 {
            searchController.searchBar.text = trimmedSearchText
        }

        // Loại bỏ dấu khỏi chuỗi tìm kiếm
        trimmedSearchText = removeDiacritics(from: trimmedSearchText)

        // Loại bỏ ký tự đặc biệt & emoji không hợp lệ
        trimmedSearchText = filterValidCharacters(from: trimmedSearchText)

        // Nếu ô tìm kiếm có nội dung sai, tự động cập nhật lại text
        if searchController.searchBar.text != trimmedSearchText {
            searchController.searchBar.text = trimmedSearchText
        }

        // Kiểm tra nếu ô tìm kiếm trống thì hiển thị toàn bộ danh sách
        if trimmedSearchText.isEmpty {
            isSearching = false // Khi xóa nội dung tìm kiếm, cho phép gọi API khi scroll
            filteredPhotos = photos
        } else {
            filteredPhotos = photos.filter { photo in
                return photo.id.contains(trimmedSearchText) || photo.author.lowercased().contains(trimmedSearchText.lowercased())
            }
        }

        tableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false // Khi bấm "Cancel", cho phép gọi API khi scroll
        filteredPhotos = photos
        tableView.reloadData()
    }
}
