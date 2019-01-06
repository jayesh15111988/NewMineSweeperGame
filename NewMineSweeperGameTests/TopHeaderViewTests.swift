//
//  TopHeaderViewTests.swift
//  NewMineSweeperGameTests
//
//  Created by Jayesh Kawli on 1/5/19.
//  Copyright © 2019 Jayesh Kawli. All rights reserved.
//

import XCTest
@testable import NewMineSweeperGame

class TopHeaderViewTests: XCTestCase {

    func testViewModel() {
        let headerViewModel = TopHeaderView.ViewModel(score: 100, gridSize: 5)
        XCTAssertEqual(headerViewModel.score, 100)
        XCTAssertEqual(headerViewModel.gridSize, 5)
    }

    func testTopHeaderView() {
        let headerViewModel = TopHeaderView.ViewModel(score: 0, gridSize: 5)
        let headerView = TopHeaderView(viewModel: headerViewModel)

        XCTAssertNotNil(headerView.viewModel)
        XCTAssertEqual(headerView.scoreLabel.text, "Score: 0")
        XCTAssertEqual(headerView.gridSizeInputField.text, "5")
    }

    func testUpdateMethods() {
        let headerViewModel = TopHeaderView.ViewModel(score: 0, gridSize: 5)
        let headerView = TopHeaderView(viewModel: headerViewModel)

        headerView.updateScore(value: 100)
        XCTAssertEqual(headerView.viewModel.score, 100)
        XCTAssertEqual(headerView.scoreLabel.text, "Score: 100")

        headerView.updateGridSize(value: 10)
        XCTAssertEqual(headerView.viewModel.gridSize, 10)
        XCTAssertEqual(headerView.gridSizeInputField.text, "10")
    }

    func testGridSizeChangedTriggerMethod() {
        let headerViewModel = TopHeaderView.ViewModel(score: 0, gridSize: 5)
        let headerView = TopHeaderView(viewModel: headerViewModel)

        headerView.gridSizeChanged(newSize: 0)
        XCTAssertEqual(headerViewModel.gridSize, 5)

        headerView.gridSizeChanged(newSize: 8)
        XCTAssertEqual(headerView.viewModel.gridSize, 8)

        let textFieldWithInvalidInput = UITextField(frame: .zero)
        textFieldWithInvalidInput.text = "abc"
        headerView.textFieldDidChange(textField: textFieldWithInvalidInput)
        XCTAssertEqual(headerViewModel.gridSize, 5)

        let textFieldWithValidInput = UITextField(frame: .zero)
        textFieldWithValidInput.text = "12"
        headerView.textFieldDidChange(textField: textFieldWithValidInput)
        XCTAssertEqual(headerView.viewModel.gridSize, 12)
    }

    func testThatInputFieldResignsAsFirstResponderWhenDoneButtonPressed() {
        let headerViewModel = TopHeaderView.ViewModel(score: 0, gridSize: 5)
        let headerView = TopHeaderView(viewModel: headerViewModel)
        headerView.gridSizeInputField.becomeFirstResponder()
        headerView.gridSizeUpdateDoneButtonPressed()
        XCTAssertFalse(headerView.gridSizeInputField.isFirstResponder)
    }

    func testThatResetClosureGetsCalled() {
        var headerViewModel = TopHeaderView.ViewModel(score: 0, gridSize: 5)

        var resetClosureCalled = false

        headerViewModel.resetButtonActionClosure = {
            resetClosureCalled = true
        }
        let headerView = TopHeaderView(viewModel: headerViewModel)
        headerView.resetButtonPressed()
        XCTAssertTrue(resetClosureCalled)
    }

    func testThatRevealClosureGetsCalled() {
        var headerViewModel = TopHeaderView.ViewModel(score: 0, gridSize: 5)

        var revealClosureCalled = false

        headerViewModel.revealButtonActionClosure = {
            revealClosureCalled = true
        }
        let headerView = TopHeaderView(viewModel: headerViewModel)
        headerView.revealButtonPressed()
        XCTAssertTrue(revealClosureCalled)
    }    
}
