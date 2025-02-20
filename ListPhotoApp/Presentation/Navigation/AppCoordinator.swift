//
//  AppCoordinator.swift
//  ListPhotoApp
//
//  Created by Thạch Khánh on 20/2/25.
//

import UIKit

class AppCoordinator {
    var window: UIWindow?

    func start(in window: UIWindow) {
        self.window = window
        let navigationController = UINavigationController(rootViewController: PhotoListViewController())
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
