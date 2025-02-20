import UIKit

class PhotoCell: UITableViewCell {
    static let identifier = "PhotoCell"

    private let photoImageView = UIImageView()
    private let authorLabel = UILabel()
    private let sizeLabel = UILabel() // Label hiển thị kích thước ảnh

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(photoImageView)
        contentView.addSubview(authorLabel)
        contentView.addSubview(sizeLabel) // Thêm sizeLabel vào contentView
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            photoImageView.heightAnchor.constraint(equalToConstant: 200),

            authorLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 8),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            sizeLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 4), // Hiển thị ngay dưới tên tác giả
            sizeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            sizeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            sizeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with photo: Photo) {
        authorLabel.text = "📸 \(photo.author)"
        sizeLabel.text = "📏 \(photo.width) x \(photo.height)" // Hiển thị kích thước ảnh
        photoImageView.image = nil

        if let cachedImage = ImageCache.shared.get(forKey: photo.downloadURL) {
            photoImageView.image = cachedImage
            return
        }

        DispatchQueue.global().async {
            if let url = URL(string: photo.downloadURL), let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                ImageCache.shared.set(image, forKey: photo.downloadURL)
                DispatchQueue.main.async {
                    self.photoImageView.image = image
                }
            }
        }
    }
}
