//
//  GameHomePageViewController.swift
//  NewMineSweeperGame
//
//  Created by Jayesh Kawli on 1/1/19.
//  Copyright © 2019 Jayesh Kawli. All rights reserved.
//

import UIKit

class GameHomePageViewController: UIViewController {

    enum Constants {
        static let horizontalPadding: CGFloat = 10.0
        static let verticalPadding: CGFloat = 8.0
        static let defaultViewHeight: CGFloat = 50.0
    }

    enum GameStateConstants {
        
    }

    enum GameState {
        case notStarted
        case inProgress
        case overAndWin
        case overAndLoss
        case busy
    }

    var topHeaderView: TopHeaderView!

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    struct ViewModel {

        let tileWidth: Double
        let totalTilesInRow: Int
        let gutterSpacing: Double
        let totalNumberOfMines: Int
        var currentGameState: GameState
        var totalNumberOfTilesRevealed: Int
        var currentScoreValue: Int

        // Represents both height and width
        func gridDimension() -> Int {
            let tilesInRow = Double(totalTilesInRow)
            return Int((tileWidth * tilesInRow) + (gutterSpacing * (tilesInRow - 1)))
        }

        func totalNumberOfTilesOnScreen() -> Int {
            return Int(pow(Double(totalTilesInRow), 2.0))
        }

        func didUserWinCurrentGame() -> Bool {
            return self.totalNumberOfTilesRevealed == self.totalNumberOfTilesOnScreen() - self.totalNumberOfMines
        }
    }

    let gridHolderView = UIView(frame: .zero)
    var viewModel = ViewModel(tileWidth: 50, totalTilesInRow: 5, gutterSpacing: 5, totalNumberOfMines: 5, currentGameState: .notStarted, totalNumberOfTilesRevealed: 0, currentScoreValue: 0)
    var minesLocationHolder: [Int: Bool] = [:]
    var numberOfSurroundingMinesHolder: [Int: Int] = [:]

    var minesButtonsHolder: [MineButton] = []
    var regularButtonsHolder: [MineButton] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "Blasting Minesweeper"
        layoutCustomViews()
        configureCustomViews()
    }
}

private extension GameHomePageViewController {
    func makeHeaderViewModel() -> TopHeaderView.ViewModel {
        var topHeaderViewModel = TopHeaderView.ViewModel(score: 0, gridSize: 10, isRevealing: true)

        topHeaderViewModel.changeGridSizeButtonActionClosure = { [weak self] newGridSize in
            print(self.debugDescription)
        }

        topHeaderViewModel.resetButtonActionClosure = { [weak self] in
            print(self.debugDescription)
        }

        topHeaderViewModel.revealButtonActionClosure = { [weak self] isRevealing in
            self?.toggleMinesDisplayState(isRevealing: isRevealing)
        }
        return topHeaderViewModel
    }

    func toggleMinesDisplayState(isRevealing: Bool) {
        for mineTile in minesButtonsHolder {
            if isRevealing {
                mineTile.stateViewModel.state = .revealed
                mineTile.showImage(with: "mine")
            } else {
                mineTile.stateViewModel.state = .notSelected
                mineTile.hideImage()
            }
            mineTile.updateBackgroundColor()
        }
    }
}

extension GameHomePageViewController: ViewsCustomizable {
    func layoutCustomViews() {
        topHeaderView = TopHeaderView(viewModel: makeHeaderViewModel())
    }

    func configureCustomViews() {
        gridHolderView.translatesAutoresizingMaskIntoConstraints = false
        gridHolderView.backgroundColor = .black
        gridHolderView.clipsToBounds = true
        gridHolderView.layer.cornerRadius = 10.0
        gridHolderView.layer.borderWidth = 2.0
        gridHolderView.layer.borderColor = UIColor.black.cgColor
        self.createNewGridOnScreen()
    }
}

extension GameHomePageViewController {

    func createNewGridOnScreen() {
        populateMinesHolder(with: viewModel.totalTilesInRow)
        let gridDimension = viewModel.gridDimension()

        var buttonSequenceNumber = 0
        var totalNumberOfMinesSurroundingGivenTile = 0

        let successiveTilesDistanceIncrement = Int(viewModel.tileWidth + viewModel.gutterSpacing)

        var yPosition = 0

        while yPosition < gridDimension {

            var xPosition = 0

            while xPosition < gridDimension {

                buttonSequenceNumber = ((xPosition / successiveTilesDistanceIncrement) +
                    (yPosition / successiveTilesDistanceIncrement) * viewModel.totalTilesInRow);

                let doesMineExistForTile = self.minesLocationHolder[buttonSequenceNumber] != nil

                totalNumberOfMinesSurroundingGivenTile = self.numberOfSurroundingMinesHolder[buttonSequenceNumber] ?? 0

                let tileButton = MineButton(position: CGPoint(x: xPosition, y: yPosition), dimension: CGFloat(viewModel.tileWidth), isMine: doesMineExistForTile, sequenceNumber: buttonSequenceNumber, numberOfSurroundingMines: totalNumberOfMinesSurroundingGivenTile)

                tileButton.stateViewModel.sequenceOfSurroundingTiles = NeighboringTilesProvider.neighboringTilesForGivenMineTile(with: buttonSequenceNumber, totalNumberOfTilesInRow: viewModel.totalTilesInRow)

                tileButton.gameOverClosure = { [weak self] in
                    //TODO: Show all mines
                    self?.updateGameState()
                    self?.showAllMines()
                    self?.showAlert(with: "You clicked on mine and now game is over")
                    print(self.debugDescription)
                }

                tileButton.tileSelectedClosure = { [weak self] sequence in
                    guard let strongSelf = self, !strongSelf.isGameOver() else { return }
                    strongSelf.highlightNeighboringButtons(with: sequence)
                }

                if doesMineExistForTile {
                    minesButtonsHolder.append(tileButton)
                } else {
                    regularButtonsHolder.append(tileButton)
                }

                let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesturePressHandler(with:)))
                tileButton.addGestureRecognizer(longPressGesture)
                gridHolderView.addSubview(tileButton)

                xPosition = xPosition + successiveTilesDistanceIncrement
            }
            yPosition = yPosition + successiveTilesDistanceIncrement
        }

        layoutViewsWithMinesweeperGrid()
    }

    func layoutViewsWithMinesweeperGrid() {

        let totalGridViewHeight = viewModel.gridDimension()

        let scrollViewAutoLayout = ScrollViewAutolayoutCreator(parentView: self.view)
        scrollViewAutoLayout.contentView.addSubview(topHeaderView)
        scrollViewAutoLayout.contentView.addSubview(gridHolderView)

        let viewsDictionary = ["gridHolderView": gridHolderView, "topHeaderView": topHeaderView!]
        let metrics = ["totalGridViewHeight": totalGridViewHeight]

        //TODO: Replace it with Anchor constraints

        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[topHeaderView(44)]-[gridHolderView(totalGridViewHeight)]-20-|", options: [], metrics: metrics, views: viewsDictionary))

        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[topHeaderView]-|", options: [], metrics: metrics, views: viewsDictionary))

        if CGFloat(totalGridViewHeight) > self.view.frame.width {
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[gridHolderView(totalGridViewHeight)]-44-|", options: [], metrics: metrics, views: viewsDictionary))
        } else {
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[gridHolderView(totalGridViewHeight)]", options: [], metrics: metrics, views: viewsDictionary))
        }
    }

    @objc func longPressGesturePressHandler(with gesture: UIGestureRecognizer) {
        guard gesture.state == .ended, let tileButton = gesture.view as? MineButton, tileButton.stateViewModel.state != .selected else { return }

        let currentState = tileButton.stateViewModel.state

        if currentState == .questionMark {
            tileButton.stateViewModel.state = .notSelected
        } else {
            tileButton.stateViewModel.state = .questionMark
        }
        tileButton.updateBackgroundColor()

        if tileButton.stateViewModel.state == .questionMark {
            tileButton.setTitle("?", for: .normal)
        } else {
            tileButton.setTitle("", for: .normal)
        }
    }

    func highlightNeighboringButtons(with sequenceNumber: Int) {
        guard let mineButton = regularButtonsHolder.first(where: { $0.sequenceNumber == sequenceNumber }) else { return }

        if !mineButton.stateViewModel.isVisited {
            
            viewModel.totalNumberOfTilesRevealed = viewModel.totalNumberOfTilesRevealed + 1
            mineButton.stateViewModel.isVisited = true            
            mineButton.updateBackgroundColor()

            if mineButton.stateViewModel.numberOfSurroundingMines == 0 {
                viewModel.currentScoreValue = viewModel.currentScoreValue + 1

                let surroundingTilesSequence = mineButton.stateViewModel.sequenceOfSurroundingTiles

                for sequence in surroundingTilesSequence {
                    self.highlightNeighboringButtons(with: sequence)
                }
            } else {
                mineButton.setTitle("\(mineButton.stateViewModel.numberOfSurroundingMines)", for: .normal)
                viewModel.currentScoreValue = viewModel.currentScoreValue + (1 * mineButton.stateViewModel.numberOfSurroundingMines)
            }

            topHeaderView.updateScore(score: viewModel.currentScoreValue)

            //TODO: Add additional logic to check if user has won
            if self.viewModel.didUserWinCurrentGame() {
                print("You won")
            }
        }
    }

    func isGameOver() -> Bool {
        return self.viewModel.currentGameState == .overAndWin || self.viewModel.currentGameState == .overAndLoss
    }

    func populateMinesHolder(with numberOfTilesInRow: Int) {

        var minesGeneratedSoFar = 0

        let maximumTileNumber = viewModel.totalNumberOfTilesOnScreen()

        while (minesGeneratedSoFar < viewModel.totalNumberOfMines) {

            let generateRandomMinesSequence = Int.random(in: 0..<maximumTileNumber)
            if minesLocationHolder[generateRandomMinesSequence] == nil {
                minesGeneratedSoFar = minesGeneratedSoFar + 1
                self.neighboringCellsForGivenMine(with: generateRandomMinesSequence)
                minesLocationHolder[generateRandomMinesSequence] = true
            }
        }

    }

    func neighboringCellsForGivenMine(with minesTileSequenceNumber: Int) {
        let resultantNeightbors = NeighboringTilesProvider.neighboringTilesForGivenMineTile(with: minesTileSequenceNumber, totalNumberOfTilesInRow: viewModel.totalTilesInRow)

        for neighborSequence in resultantNeightbors {
            if let previousPointValue = numberOfSurroundingMinesHolder[neighborSequence] {
                numberOfSurroundingMinesHolder[neighborSequence] = previousPointValue + 1
            } else {
                numberOfSurroundingMinesHolder[neighborSequence] = 1
            }
        }
    }
}

extension GameHomePageViewController {

    func updateGameState() {
        self.viewModel.currentGameState = .overAndLoss
    }

    func showAllMines() {
        for mineButtons in minesButtonsHolder {
            mineButtons.showImage(with: "skull")
        }
    }

    func showAlert(with message: String) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
