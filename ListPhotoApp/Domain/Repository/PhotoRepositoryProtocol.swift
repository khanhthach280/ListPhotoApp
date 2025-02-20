//
//  PhotoRepositoryProtocol.swift
//  ListPhotoApp
//
//  Created by Thạch Khánh on 20/2/25.
//
import Foundation

protocol PhotoRepositoryProtocol {
    func getPhotos(page: Int, completion: @escaping ([Photo]?) -> Void)
}

