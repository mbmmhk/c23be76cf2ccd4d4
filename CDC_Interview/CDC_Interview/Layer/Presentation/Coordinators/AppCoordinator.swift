//
//  MainCoordinator.swift
//  CDC_Interview
//
//  Created by Junjie Gu on 2025/8/14.
//

import UIKit
import SwiftUI

// Base Coordinator protocol for managing app navigation flow
protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }

    /// Starts the coordinator and presents the initial view
    func start()
}

extension Coordinator {
    func addChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }

    func removeChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
}

class AppCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    private let tabBarController: UITabBarController
    private let listNavController: UINavigationController
    private let settingsNavController: UINavigationController

    init(tabBarController: UITabBarController) {
        self.tabBarController = tabBarController

        // Create navigation controllers
        self.listNavController = UINavigationController()
        listNavController.tabBarItem.title = "Price List"
        listNavController.tabBarItem.image = UIImage(systemName: "list.bullet")

        self.settingsNavController = UINavigationController()
        settingsNavController.tabBarItem.title = "Settings"
        settingsNavController.tabBarItem.image = UIImage(systemName: "gear")

        // Configure navigation bar appearance globally
        configureNavigationBarAppearance()
    }

    func start() {
        setupTabs()
        startChildCoordinators()
    }

    private func setupTabs() {
        tabBarController.viewControllers = [
            listNavController,
            settingsNavController
        ]
    }

    private func startChildCoordinators() {
        // Start crypto list coordinator
        let cryptoCoordinator = CryptoListCoordinator(navigationController: listNavController)
        addChildCoordinator(cryptoCoordinator)
        cryptoCoordinator.start()

        // Start settings coordinator (for future expansion)
        let settingsCoordinator = SettingsCoordinator(navigationController: settingsNavController)
        addChildCoordinator(settingsCoordinator)
        settingsCoordinator.start()
    }

    private func configureNavigationBarAppearance() {
        // Configure navigation bar appearance for both navigation controllers
        configureNavigationController(listNavController)
        configureNavigationController(settingsNavController)
    }

    private func configureNavigationController(_ navController: UINavigationController) {
        // Set tint color for back button and other navigation items
        navController.navigationBar.tintColor = .black

        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()

        // Hide back button text by setting empty back button title
        appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.backButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.clear]

        // Set back button appearance - only arrow, no text
        appearance.setBackIndicatorImage(
            UIImage(systemName: "chevron.left")?.withConfiguration(
                UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
            ),
            transitionMaskImage: UIImage(systemName: "chevron.left")?.withConfiguration(
                UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
            )
        )

        navController.navigationBar.standardAppearance = appearance
        navController.navigationBar.scrollEdgeAppearance = appearance
        navController.navigationBar.compactAppearance = appearance
    }
}


