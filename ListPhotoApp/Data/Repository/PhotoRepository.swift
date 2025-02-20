import Foundation

//protocol PhotoRepositoryProtocol {
//    func getPhotos(page: Int, completion: @escaping ([Photo]?) -> Void)
//}

class PhotoRepository: PhotoRepositoryProtocol {
    func getPhotos(page: Int, completion: @escaping ([Photo]?) -> Void) {
        APIService.shared.fetchPhotos(page: page, completion: completion)
    }
}
