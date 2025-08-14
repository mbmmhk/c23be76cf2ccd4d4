//
//  AppCoordinatorTests.swift
//  CDC_InterviewTests
//
//  Created by Junjie Gu on 2025/8/14.
//

import XCTest
import UIKit
@testable import CDC_Interview

final class AppCoordinatorTests: XCTestCase {

    var sut: AppCoordinator!
    var mockTabBarController: UITabBarController!

    override func setUp() {
        super.setUp()
        mockTabBarController = UITabBarController()
        sut = AppCoordinator(tabBarController: mockTabBarController)
    }

    override func tearDown() {
        sut = nil
        mockTabBarController = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInit_ShouldInitializeWithTabBarController() {
        // Given & When
        let coordinator = AppCoordinator(tabBarController: mockTabBarController)

        // Then
        XCTAssertNotNil(coordinator)
        XCTAssertTrue(coordinator.childCoordinators.isEmpty)
    }

    // MARK: - Start Method Tests

    func testStart_ShouldSetupTabBarWithTwoViewControllers() {
        // When
        sut.start()

        // Then
        XCTAssertEqual(mockTabBarController.viewControllers?.count, 2)
    }

    func testStart_ShouldCreateNavigationControllersWithCorrectTitles() {
        // When
        sut.start()

        // Then
        guard let viewControllers = mockTabBarController.viewControllers,
              let firstNavController = viewControllers[0] as? UINavigationController,
              let secondNavController = viewControllers[1] as? UINavigationController else {
            XCTFail("Expected navigation controllers")
            return
        }

        XCTAssertEqual(firstNavController.tabBarItem.title, "Price List")
        XCTAssertEqual(secondNavController.tabBarItem.title, "Settings")
    }

    func testStart_ShouldSetCorrectTabBarIcons() {
        // When
        sut.start()

        // Then
        guard let viewControllers = mockTabBarController.viewControllers,
              let firstNavController = viewControllers[0] as? UINavigationController,
              let secondNavController = viewControllers[1] as? UINavigationController else {
            XCTFail("Expected navigation controllers")
            return
        }

        XCTAssertEqual(firstNavController.tabBarItem.image, UIImage(systemName: "list.bullet"))
        XCTAssertEqual(secondNavController.tabBarItem.image, UIImage(systemName: "gear"))
    }

    func testStart_ShouldCreateTwoChildCoordinators() {
        // When
        sut.start()

        // Then
        XCTAssertEqual(sut.childCoordinators.count, 2)
    }

    func testStart_ShouldCreateCryptoListCoordinatorAsFirstChild() {
        // When
        sut.start()

        // Then
        XCTAssertTrue(sut.childCoordinators[0] is CryptoListCoordinator)
    }

    func testStart_ShouldCreateSettingsCoordinatorAsSecondChild() {
        // When
        sut.start()

        // Then
        XCTAssertTrue(sut.childCoordinators[1] is SettingsCoordinator)
    }

    // MARK: - Child Coordinator Management Tests

    func testAddChildCoordinator_ShouldAddCoordinatorToChildArray() {
        // Given
        let mockCoordinator = MockCoordinator()

        // When
        sut.addChildCoordinator(mockCoordinator)

        // Then
        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators[0] === mockCoordinator)
    }

    func testRemoveChildCoordinator_ShouldRemoveCoordinatorFromChildArray() {
        // Given
        let mockCoordinator = MockCoordinator()
        sut.addChildCoordinator(mockCoordinator)

        // When
        sut.removeChildCoordinator(mockCoordinator)

        // Then
        XCTAssertTrue(sut.childCoordinators.isEmpty)
    }

    func testRemoveChildCoordinator_ShouldOnlyRemoveSpecificCoordinator() {
        // Given
        let mockCoordinator1 = MockCoordinator()
        let mockCoordinator2 = MockCoordinator()
        sut.addChildCoordinator(mockCoordinator1)
        sut.addChildCoordinator(mockCoordinator2)

        // When
        sut.removeChildCoordinator(mockCoordinator1)

        // Then
        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators[0] === mockCoordinator2)
    }
}

// MARK: - Mock Objects

class MockCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var startCalled = false

    func start() {
        startCalled = true
    }
}
