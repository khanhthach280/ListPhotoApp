//
//  SearchHelper.swift
//  ListPhotoApp
//
//  Created by Thạch Khánh on 20/2/25.
//
import Foundation

class SearchHelper {
    static func cleanSearchText(_ text: String) -> String {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*():.,<>/\\[]? ")
        return text.unicodeScalars.filter { allowedCharacters.contains($0) }.map { String($0) }.joined()
    }
}

