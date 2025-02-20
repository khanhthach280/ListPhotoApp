//
//  PhotoCell.swift
//  ListPhotoApp
//
//  Created by Thạch Khánh on 20/2/25.
//
import UIKit

class PhotoCell: UITableViewCell {
    static let identifier = "PhotoCell"
    private let photoImageView = UIImageView()
    private let authorLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(photoImageView)
        contentView.addSubview(authorLabel)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            photoImageView.heightAnchor.constraint(equalToConstant: 200),
            authorLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 8),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            authorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with photo: Photo) {
        authorLabel.text = "📸 \(photo.author)"
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

