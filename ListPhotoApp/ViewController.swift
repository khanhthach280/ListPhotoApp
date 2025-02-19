import UIKit

class ViewController: UIViewController {
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private var photos: [Photo] = []
    private var currentPage = 1
    private var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
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

    @objc private func refreshPhotos() {
        currentPage = 1
        fetchPhotos()
    }

    private func fetchPhotos(loadMore: Bool = false) {
        if isLoading { return }
        isLoading = true

        APIService.shared.fetchPhotos(page: currentPage) { [weak self] newPhotos in
            guard let self = self, let newPhotos = newPhotos else {
                self?.isLoading = false
                return
            }

            if loadMore {
                self.photos.append(contentsOf: newPhotos)
            } else {
                self.photos = newPhotos
            }

            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                self.isLoading = false
            }
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as? PhotoCell else {
            return UITableViewCell()
        }
        cell.configure(with: photos[indexPath.row])
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        let threshold: CGFloat = 100  // Chỉ load thêm khi gần hết danh sách

        if offsetY > contentHeight - frameHeight - threshold {
            if !isLoading {
                currentPage += 1
                fetchPhotos(loadMore: true)
            }
        }
    }
}
