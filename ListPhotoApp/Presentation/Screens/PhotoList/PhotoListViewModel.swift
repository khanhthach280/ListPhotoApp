import Foundation

class PhotoListViewModel {
    private var getPhotosUseCase: GetPhotosUseCase
    private var photos: [Photo] = []
    var filteredPhotos: [Photo] = []
    var onDataUpdated: (() -> Void)?
    private var currentPage = 1
    private var isLoadingMore = false
    private var isSearching = false // Biến để kiểm tra trạng thái tìm kiếm

    init(getPhotosUseCase: GetPhotosUseCase = GetPhotosUseCase(repository: PhotoRepository())) {
        self.getPhotosUseCase = getPhotosUseCase
    }

    func fetchPhotos(page: Int = 1) {
        guard !isSearching else { return } // Không gọi API khi đang search
        getPhotosUseCase.execute(page: page) { [weak self] newPhotos in
            guard let self = self, let newPhotos = newPhotos else { return }
            self.photos = newPhotos
            self.filteredPhotos = newPhotos
            self.onDataUpdated?()
        }
    }

    func loadMorePhotos() {
        guard !isLoadingMore, !isSearching else { return } // Không gọi API khi đang search
        isLoadingMore = true
        currentPage += 1
        getPhotosUseCase.execute(page: currentPage) { [weak self] newPhotos in
            guard let self = self, let newPhotos = newPhotos else { return }
            self.photos.append(contentsOf: newPhotos)
            self.filteredPhotos.append(contentsOf: newPhotos)
            self.isLoadingMore = false
            self.onDataUpdated?()
        }
    }

    func refreshPhotos() {
        fetchPhotos()
    }

    func search(text: String?) {
        guard let text = text, !text.isEmpty else {
            isSearching = false
            filteredPhotos = photos
            onDataUpdated?()
            return
        }
        
        isSearching = true
        let cleanedText = SearchHelper.cleanSearchText(text)
        filteredPhotos = photos.filter { $0.id.contains(cleanedText) || $0.author.lowercased().contains(cleanedText.lowercased()) }
        onDataUpdated?()
    }
}
