//
//  CryptoListCoordinator.swift
//  CDC_Interview
//
//  Created by Junjie Gu on 2025/8/14.
//

import Foundation
import UIKit
import SwiftUI

// Protocol for handling navigation from CryptoListView
protocol CryptoListCoordinatorProtocol: AnyObject {
    func showDetail(for item: CryptoListViewModel.DisplayItem)
}

// Coordinator for managing crypto list navigation flow
class CryptoListCoordinator: Coordinator, CryptoListCoordinatorProtocol {
    var childCoordinators = [Coordinator]()
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showCryptoList()
    }

    private func showCryptoList() {
        var cryptoListView = CryptoListView()
        cryptoListView.coordinator = self
        let hostingController = UIHostingController(rootView: cryptoListView)
        hostingController.title = "Price List"
        navigationController.pushViewController(hostingController, animated: false)
    }

    func showDetail(for item: CryptoListViewModel.DisplayItem) {
        let detailView = DetailView(displayItem: item)
        let detailViewController = UIHostingController(rootView: detailView)
        detailViewController.title = item.name
        detailViewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(detailViewController, animated: true)
    }
}
