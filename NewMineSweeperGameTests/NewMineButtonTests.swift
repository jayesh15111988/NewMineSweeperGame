//
//  NewMineButtonTests.swift
//  NewMineSweeperGameTests
//
//  Created by Jayesh Kawli on 1/5/19.
//  Copyright © 2019 Jayesh Kawli. All rights reserved.
//

import XCTest
@testable import NewMineSweeperGame

class NewMineButtonTests: XCTestCase {

    func testMineButtonColorAssociatedWithState() {
        XCTAssertEqual(MineButton.MineButtonstate.selected.color(), .blue)
        XCTAssertEqual(MineButton.MineButtonstate.notSelected.color(), .red)
        XCTAssertEqual(MineButton.MineButtonstate.questionMark.color(), .white)
        XCTAssertEqual(MineButton.MineButtonstate.revealed.color(), .green)
    }

    func testThatStateViewModelStateIsUpdatedAfterVisit() {
        var stateViewModel = MineButton.StateViewModel(isMine: true, state: .notSelected, numberOfSurroundingMines: 10, sequenceOfSurroundingTiles: [1, 2], sequenceNumber: 3, isVisited: false)
        XCTAssertEqual(stateViewModel.state, .notSelected)
        stateViewModel.isVisited = true
        XCTAssertEqual(stateViewModel.state, .selected)
    }

    func testViewModel() {
        let stateViewModel = MineButton.StateViewModel(isMine: true, state: .questionMark, numberOfSurroundingMines: 10, sequenceOfSurroundingTiles: [1, 2], sequenceNumber: 3, isVisited: true)
        XCTAssertEqual(stateViewModel.isMine, true)
        XCTAssertEqual(stateViewModel.state, .questionMark)
        XCTAssertEqual(stateViewModel.numberOfSurroundingMines, 10)
        XCTAssertEqual(stateViewModel.sequenceOfSurroundingTiles, [1, 2])
        XCTAssertEqual(stateViewModel.sequenceNumber, 3)
        XCTAssertEqual(stateViewModel.isVisited, true)
    }

    func testMineButtonInitializationLogic() {
        let mineButton = MineButton(position: .zero, dimension: 10, isMine: true, sequenceNumber: 1, numberOfSurroundingMines: 3, sequenceOfSurroundingTiles: [1, 2])
        XCTAssertNotNil(mineButton.stateViewModel)
        XCTAssertEqual(mineButton.backgroundColor, .red)
        XCTAssertEqual(mineButton.titleLabel?.text, nil)
        XCTAssertEqual(mineButton.overlayImageView.alpha, 0.0, accuracy: 0.01)
        XCTAssertEqual(mineButton.frame.width, 10)
        XCTAssertEqual(mineButton.frame.height, 10)
    }

    func testWhenTileIsSelected() {
        let mineButton = MineButton(position: .zero, dimension: 10, isMine: true, sequenceNumber: 1, numberOfSurroundingMines: 3, sequenceOfSurroundingTiles: [1, 2])
        var isGameOver = false
        mineButton.gameOverClosure = {
            isGameOver = true
        }
        mineButton.tileButtonSelected()
        XCTAssertTrue(isGameOver)

        let regularButton = MineButton(position: .zero, dimension: 10, isMine: false, sequenceNumber: 10, numberOfSurroundingMines: 3, sequenceOfSurroundingTiles: [1, 2])
        isGameOver = false

        var isTileSelected = false
        var selectedSequence = -1
        regularButton.tileSelectedClosure = { sequence in
            isTileSelected = true
            selectedSequence = sequence
        }

        XCTAssertEqual(regularButton.stateViewModel.state, .notSelected)
        regularButton.tileButtonSelected()
        XCTAssertFalse(isGameOver)
        XCTAssertEqual(regularButton.stateViewModel.state, .selected)
        XCTAssertTrue(isTileSelected)
        XCTAssertEqual(selectedSequence, 10)
    }

    func testShowImageMethod() {
        let mineButton = MineButton(position: .zero, dimension: 10, isMine: true, sequenceNumber: 1, numberOfSurroundingMines: 3, sequenceOfSurroundingTiles: [1, 2])
        mineButton.showImage(with: ImageName.mine)
        XCTAssertNotNil(mineButton.overlayImageView.image)
    }

    func testHideImageMethod() {
        let mineButton = MineButton(position: .zero, dimension: 10, isMine: true, sequenceNumber: 1, numberOfSurroundingMines: 3, sequenceOfSurroundingTiles: [1, 2])
        mineButton.hideImage()
        XCTAssertNil(mineButton.overlayImageView.image)
    }

    func testToggleMineVisibility() {
        let mineButton = MineButton(position: .zero, dimension: 10, isMine: true, sequenceNumber: 1, numberOfSurroundingMines: 3, sequenceOfSurroundingTiles: [1, 2])
        mineButton.toggleMineVisibility(toShow: true)
        XCTAssertEqual(mineButton.stateViewModel.state, .revealed)
        XCTAssertNotNil(mineButton.overlayImageView.image)
        XCTAssertEqual(mineButton.overlayImageView.alpha, 1.0, accuracy: 0.01)

        mineButton.toggleMineVisibility(toShow: false)
        XCTAssertEqual(mineButton.stateViewModel.state, .notSelected)
        XCTAssertNil(mineButton.overlayImageView.image)
        XCTAssertEqual(mineButton.overlayImageView.alpha, 0.0, accuracy: 0.01)
    }

    func testUpdateQuestionMarkState() {
        let mineButton = MineButton(position: .zero, dimension: 10, isMine: true, sequenceNumber: 1, numberOfSurroundingMines: 3, sequenceOfSurroundingTiles: [1, 2])

        mineButton.updateStateWithQuestionMark()

        XCTAssertEqual(mineButton.stateViewModel.state, .questionMark)
        XCTAssertEqual(mineButton.title(for: .normal), "?")

        mineButton.updateStateWithQuestionMark()

        XCTAssertEqual(mineButton.stateViewModel.state, .notSelected)
        XCTAssertEqual(mineButton.title(for: .normal), "")
    }

    func testGameOverState() {
        let mine = MineButton(position: .zero, dimension: 10, isMine: true, sequenceNumber: 3, numberOfSurroundingMines: 1, sequenceOfSurroundingTiles: [0, 1, 4, 6, 7])
        var isGameOver = false
        mine.gameOverClosure  = {
            isGameOver = true
        }
        mine.tileButtonSelected()
        XCTAssertTrue(isGameOver)
    }
}
