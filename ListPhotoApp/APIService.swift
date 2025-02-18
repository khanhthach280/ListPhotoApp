import Foundation

class APIService {
    static let shared = APIService()

    func fetchPhotos(page: Int = 1, completion: @escaping ([Photo]?) -> Void) {
        let urlString = "https://picsum.photos/v2/list?page=\(page)&limit=20"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Lỗi API: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                completion(nil)
                return
            }

            do {
                let photos = try JSONDecoder().decode([Photo].self, from: data)
                DispatchQueue.main.async {
                    completion(photos)
                }
            } catch {
                print("Lỗi JSON: \(error)")
                completion(nil)
            }
        }.resume()
    }
}
