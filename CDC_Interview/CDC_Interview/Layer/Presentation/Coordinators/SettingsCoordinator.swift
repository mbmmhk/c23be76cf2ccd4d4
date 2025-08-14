//
//  SettingsCoordinator.swift
//  CDC_Interview
//
//  Created by Junjie Gu on 2025/8/14.
//

import Foundation
import UIKit
import SwiftUI

// Coordinator for managing settings navigation flow
class SettingsCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showSettings()
    }
    
    private func showSettings() {
        let settingView = SettingView(viewModel: .init())
        let hostingController = UIHostingController(rootView: settingView)
        hostingController.title = "Settings"
        navigationController.pushViewController(hostingController, animated: false)
    }
    
    // Future expansion: add methods for settings navigation
    // func showAbout() { ... }
    // func showPrivacyPolicy() { ... }
}
