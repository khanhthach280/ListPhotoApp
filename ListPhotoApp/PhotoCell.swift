import UIKit

class PhotoCell: UITableViewCell {
    static let identifier = "PhotoCell"

    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()

    private let sizeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(photoImageView)
        contentView.addSubview(authorLabel)
        contentView.addSubview(sizeLabel)
        
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

            sizeLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 4),
            sizeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            sizeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            sizeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with photo: Photo) {
        authorLabel.text = "📸 \(photo.author)"
        sizeLabel.text = "\(photo.width) x \(photo.height) px"
        loadImage(from: URL(string: photo.downloadURL)!)
    }

    private func loadImage(from url: URL) {
        photoImageView.image = UIImage(named: "placeholder") // Hiển thị ảnh nền tạm thời

        if let cachedImage = ImageCache.shared.get(forKey: url.absoluteString) {
            self.photoImageView.image = cachedImage
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil,
                  let image = UIImage(data: data) else { return }

            ImageCache.shared.set(image, forKey: url.absoluteString)

            DispatchQueue.main.async {
                self.photoImageView.image = image
            }
        }.resume()
    }
}
