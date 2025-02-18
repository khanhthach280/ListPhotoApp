import UIKit

class PhotoCell: UITableViewCell {
    private let photoImageView = UIImageView()
    private let authorLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(photoImageView)
        contentView.addSubview(authorLabel)

        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            photoImageView.heightAnchor.constraint(equalToConstant: 200),

            authorLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 8),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            authorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with photo: Photo) {
        authorLabel.text = "Author: \(photo.author)"
        if let url = URL(string: photo.downloadURL) {
            loadImage(from: url)
        }
    }

    private func loadImage(from url: URL) {
        photoImageView.image = nil // Reset ảnh cũ để tránh flickering

        // Kiểm tra ảnh có được cache trước đó chưa
        if let cachedImage = ImageCache.shared.get(forKey: url.absoluteString) {
            self.photoImageView.image = cachedImage
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil,
                  let image = UIImage(data: data) else { return }

            // Lưu vào cache
            ImageCache.shared.set(image, forKey: url.absoluteString)

            DispatchQueue.main.async {
                self.photoImageView.image = image
            }
        }.resume()
    }
}
