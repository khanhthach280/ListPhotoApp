//
//  GetPhotosUseCase.swift
//  ListPhotoApp
//
//  Created by Thạch Khánh on 20/2/25.
//
import Foundation

class GetPhotosUseCase {
    private let repository: PhotoRepositoryProtocol

    init(repository: PhotoRepositoryProtocol) {
        self.repository = repository
    }

    func execute(page: Int, completion: @escaping ([Photo]?) -> Void) {
        repository.getPhotos(page: page, completion: completion)
    }
}

