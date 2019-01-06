//
//  GameHomePageViewControllerTests.swift
//  NewMineSweeperGameTests
//
//  Created by Jayesh Kawli on 1/6/19.
//  Copyright © 2019 Jayesh Kawli. All rights reserved.
//

import XCTest
@testable import NewMineSweeperGame

class GameHomePageViewControllerTests: XCTestCase {

    var viewModel: GameHomePageViewController.ViewModel!
    var viewController: GameHomePageViewController!

    override func setUp() {
        viewModel = GameHomePageViewController.ViewModel(tileWidth: 50, totalTilesInRow: 10, gutterSpacing: 5, currentGameState: .notStarted, totalNumberOfTilesRevealed: 0, currentScoreValue: 10, isRevealing: true)
        viewController = GameHomePageViewController(viewModel: viewModel)
        viewController.minesButtonsHolder = [MineButton(position: .zero, dimension: 10, isMine: true, sequenceNumber: 10, numberOfSurroundingMines: 3, sequenceOfSurroundingTiles: []),
                                             MineButton(position: .zero, dimension: 10, isMine: true, sequenceNumber: 14, numberOfSurroundingMines: 3, sequenceOfSurroundingTiles: []),
                                             MineButton(position: .zero, dimension: 10, isMine: true, sequenceNumber: 24, numberOfSurroundingMines: 3, sequenceOfSurroundingTiles: [])]
    }

    func testThatViewModelIsSet() {
        XCTAssertNotNil(viewController.viewModel)
    }

    func testViewModelProperties() {
        XCTAssertEqual(viewModel.tileWidth, 50)
        XCTAssertEqual(viewModel.totalTilesInRow, 10)
        XCTAssertEqual(viewModel.gutterSpacing, 5)
        XCTAssertEqual(viewModel.currentGameState, .notStarted)
        XCTAssertEqual(viewModel.totalNumberOfTilesRevealed, 0)
        XCTAssertEqual(viewModel.currentScoreValue, 10)
        XCTAssertEqual(viewModel.isRevealing, true)
        XCTAssertEqual(viewModel.gridDimension(), 545)
        XCTAssertEqual(viewModel.totalNumberOfTilesOnScreen(), 100)
        XCTAssertEqual(viewModel.totalNumberOfMines, 25)
    }

    func testThatUserWonTheCurrentGame() {
        XCTAssertEqual(viewModel.didUserWinCurrentGame(), false)
        viewModel.totalNumberOfTilesRevealed = 75
        XCTAssertEqual(viewModel.didUserWinCurrentGame(), true)
    }

    func testTopHeaderViewModelCreation() {
        let topHeaderViewModel = viewController.makeHeaderViewModel()
        XCTAssertEqual(topHeaderViewModel.score, 10)
        XCTAssertEqual(topHeaderViewModel.gridSize, 10)

        topHeaderViewModel.changeGridSizeButtonActionClosure?(7)
        XCTAssertEqual(viewController.viewModel.totalTilesInRow, 7)

        topHeaderViewModel.revealButtonActionClosure?()
        XCTAssertEqual(viewController.viewModel.isRevealing, false)
    }

    func testMinesToggleDisplayState() {
        XCTAssertTrue(viewModel.isRevealing)
        viewController.minesButtonsHolder.forEach { (button) in
            XCTAssertEqual(button.stateViewModel.state, .notSelected)
            XCTAssertNil(button.overlayImageView.image)
            XCTAssertEqual(button.overlayImageView.alpha, 0.0, accuracy: 0.01)
        }
        viewController.toggleMinesDisplayState()
        viewController.minesButtonsHolder.forEach { (button) in
            XCTAssertEqual(button.stateViewModel.state, .revealed)
            XCTAssertNotNil(button.overlayImageView.image)
            XCTAssertEqual(button.overlayImageView.alpha, 1.0, accuracy: 0.01)
        }
    }

    func testIfGameIsOver() {
        XCTAssertFalse(viewController.isGameOver())
        viewController.viewModel.currentGameState = .overAndWin
        XCTAssertTrue(viewController.isGameOver())
    }

    func testShowAllMinesMethod() {
        viewController.minesButtonsHolder.forEach { (button) in
            XCTAssertNil(button.overlayImageView.image)
            XCTAssertEqual(button.overlayImageView.alpha, 0.0, accuracy: 0.01)
        }
        viewController.showAllMines()
        viewController.minesButtonsHolder.forEach { (button) in
            XCTAssertNotNil(button.overlayImageView.image)
            XCTAssertEqual(button.overlayImageView.alpha, 1.0, accuracy: 0.01)
        }
    }

    func testPopulateMinesHolder() {
        viewController.viewModel.totalTilesInRow = 5
        viewController.populateMinesHolder()

        XCTAssertEqual(viewController.minesLocationHolder.count, viewController.viewModel.totalNumberOfMines)
        viewController.minesLocationHolder.forEach { (key, value) in
            XCTAssertTrue(viewController.minesLocationHolder[key]!)
        }
    }

    func testPopulateNumberOfSurroundingMinesForTile() {
        viewController.viewModel.totalTilesInRow = 3
        viewController.populateNumberOfSurroundingMinesForTile(with: 3)
        viewController.populateNumberOfSurroundingMinesForTile(with: 8)

        XCTAssertEqual(viewController.numberOfSurroundingMinesHolder[0], 1)
        XCTAssertEqual(viewController.numberOfSurroundingMinesHolder[6], 1)
        XCTAssertEqual(viewController.numberOfSurroundingMinesHolder[4], 2)
        XCTAssertEqual(viewController.numberOfSurroundingMinesHolder[5], 1)
        XCTAssertNil(viewController.numberOfSurroundingMinesHolder[2])
    }

    func testHighlightTilesMethod() {
        _ = viewController.view
        viewController.viewModel.totalTilesInRow = 3
        viewController.regularButtonsHolder = [MineButton(position: .zero, dimension: 10, isMine: false, sequenceNumber: 0, numberOfSurroundingMines: 1, sequenceOfSurroundingTiles: [1, 3, 4]),
                              MineButton(position: .zero, dimension: 10, isMine: false, sequenceNumber: 1, numberOfSurroundingMines: 1, sequenceOfSurroundingTiles: [0, 3, 4, 5, 2]),
                              MineButton(position: .zero, dimension: 10, isMine: false, sequenceNumber: 2, numberOfSurroundingMines: 0, sequenceOfSurroundingTiles: [1, 4, 5]),
                              MineButton(position: .zero, dimension: 10, isMine: false, sequenceNumber: 4, numberOfSurroundingMines: 2, sequenceOfSurroundingTiles: [0, 1, 2, 3, 5, 6, 7]),
                              MineButton(position: .zero, dimension: 10, isMine: false, sequenceNumber: 5, numberOfSurroundingMines: 1, sequenceOfSurroundingTiles: [1, 2, 4, 7, 8]),
                              MineButton(position: .zero, dimension: 10, isMine: false, sequenceNumber: 7, numberOfSurroundingMines: 2, sequenceOfSurroundingTiles: [3, 4, 5, 6, 8]),
                              MineButton(position: .zero, dimension: 10, isMine: false, sequenceNumber: 6, numberOfSurroundingMines: 1, sequenceOfSurroundingTiles: [3, 4, 7])]

        viewController.minesButtonsHolder = [MineButton(position: .zero, dimension: 10, isMine: true, sequenceNumber: 3, numberOfSurroundingMines: 1, sequenceOfSurroundingTiles: [0, 1, 4, 6, 7]),
                                   MineButton(position: .zero, dimension: 10, isMine: true, sequenceNumber: 8, numberOfSurroundingMines: 1, sequenceOfSurroundingTiles: [4, 5, 7])]

        viewController.regularButtonsHolder.forEach { XCTAssertFalse($0.stateViewModel.isVisited) }
        viewController.minesButtonsHolder.forEach { XCTAssertFalse($0.stateViewModel.isVisited) }

        viewController.highlightNeighboringButtons(with: 0)

        XCTAssertEqual(viewController.viewModel.totalNumberOfTilesRevealed, 1)

        viewController.highlightNeighboringButtons(with: 2)

        XCTAssertEqual(viewController.viewModel.totalNumberOfTilesRevealed, 5)

        viewController.highlightNeighboringButtons(with: 7)

        XCTAssertEqual(viewController.viewModel.totalNumberOfTilesRevealed, 6)

        viewController.highlightNeighboringButtons(with: 6)

        XCTAssertEqual(viewController.viewModel.totalNumberOfTilesRevealed, 7)

        XCTAssertTrue(viewController.viewModel.didUserWinCurrentGame())
        viewController.regularButtonsHolder.forEach { button in
            XCTAssertTrue(button.stateViewModel.isVisited)
        }
    }    

    func testResetState() {
        _ = viewController.view
        viewController.minesLocationHolder = [10: true, 20: false]
        viewController.numberOfSurroundingMinesHolder = [1: 10, 2: 20]
        viewController.minesButtonsHolder = [MineButton(position: .zero, dimension: 10, isMine: true, sequenceNumber: 3, numberOfSurroundingMines: 1, sequenceOfSurroundingTiles: [0, 1, 4, 6, 7])]
        viewController.regularButtonsHolder = [MineButton(position: .zero, dimension: 10, isMine: false, sequenceNumber: 0, numberOfSurroundingMines: 1, sequenceOfSurroundingTiles: [1, 3, 4])]

        XCTAssertTrue(viewController.gridHolderView.subviews.count > 0)
        XCTAssertNotNil(viewController.gridHolderView.superview)
        XCTAssertNotNil(viewController.topHeaderView.superview)

        viewController.resetGame()

        XCTAssertEqual(viewController.minesLocationHolder.count, 0)
        XCTAssertEqual(viewController.numberOfSurroundingMinesHolder.count, 0)
        XCTAssertEqual(viewController.minesLocationHolder.count, 0)
        XCTAssertEqual(viewController.regularButtonsHolder.count, 0)

        XCTAssertEqual(viewController.viewModel.currentGameState, .notStarted)
        XCTAssertEqual(viewController.viewModel.totalNumberOfTilesRevealed, 0)
        XCTAssertEqual(viewController.viewModel.currentScoreValue, 0)
        XCTAssertTrue(viewController.viewModel.isRevealing)

        XCTAssertEqual(viewController.gridHolderView.subviews.count, 0)
        XCTAssertNil(viewController.gridHolderView.superview)
        XCTAssertNil(viewController.topHeaderView.superview)

        XCTAssertEqual(viewController.topHeaderView.viewModel.score, 0)
        XCTAssertEqual(viewController.topHeaderView.viewModel.gridSize, viewController.viewModel.totalTilesInRow)
    }

}
