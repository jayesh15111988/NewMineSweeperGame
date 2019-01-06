//
//  AppDelegate.swift
//  NewMineSweeperGame
//
//  Created by Jayesh Kawli on 1/1/19.
//  Copyright © 2019 Jayesh Kawli. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let viewModel = GameHomePageViewController.ViewModel(tileWidth: GameHomePageViewController.GameStateConstants.tileWidth, totalTilesInRow: GameHomePageViewController.GameStateConstants.totalTilesInRow, gutterSpacing: GameHomePageViewController.GameStateConstants.gutterSpacing, currentGameState: .notStarted, totalNumberOfTilesRevealed: 0, currentScoreValue: 0, isRevealing: true)
        let gameHomePageViewController = GameHomePageViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: gameHomePageViewController)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()

        return true
    }
}

