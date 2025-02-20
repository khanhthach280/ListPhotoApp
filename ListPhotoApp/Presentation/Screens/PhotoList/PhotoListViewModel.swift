import Foundation

class PhotoListViewModel {
    private var getPhotosUseCase: GetPhotosUseCase
    private var photos: [Photo] = []
    var filteredPhotos: [Photo] = []
    var onDataUpdated: (() -> Void)?
    private var currentPage = 1
    private var isLoadingMore = false
    private var isSearching = false

    init(getPhotosUseCase: GetPhotosUseCase = GetPhotosUseCase(repository: PhotoRepository())) {
        self.getPhotosUseCase = getPhotosUseCase
    }

    func fetchPhotos(page: Int = 1) {
        guard !isSearching else { return }
        currentPage = 1 // Reset lại page khi fetch mới
        getPhotosUseCase.execute(page: page) { [weak self] newPhotos in
            guard let self = self, let newPhotos = newPhotos else { return }
            self.photos = newPhotos
            self.filteredPhotos = newPhotos
            self.onDataUpdated?()
        }
    }

    func loadMorePhotos(completion: (() -> Void)? = nil) {
        guard !isLoadingMore, !isSearching else {
            completion?()
            return
        }
        
        isLoadingMore = true
        currentPage += 1

        getPhotosUseCase.execute(page: currentPage) { [weak self] newPhotos in
            guard let self = self, let newPhotos = newPhotos else {
                completion?()
                return
            }
            
            self.photos.append(contentsOf: newPhotos)
            self.filteredPhotos.append(contentsOf: newPhotos)
            self.isLoadingMore = false
            self.onDataUpdated?()
            completion?()
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
