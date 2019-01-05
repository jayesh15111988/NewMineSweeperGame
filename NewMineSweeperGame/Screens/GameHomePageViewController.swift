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
        static let gridCornerRadius: CGFloat = 10.0
        static let gridWidth: CGFloat = 2.0
    }

    enum GameState {
        case notStarted
        case inProgress
        case overAndWin
        case overAndLoss
        case busy
    }

    enum GameStateConstants {
        static let tileWidth: Double = 50.0
        static let totalTilesInRow = 3
        static let gutterSpacing: Double = 5.0
        static let totalNumberOfMines = 5
    }

    var topHeaderView: TopHeaderView!

    var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    struct ViewModel {

        let tileWidth: Double
        var totalTilesInRow: Int
        let gutterSpacing: Double
        var totalNumberOfMines: Int {
            return Int(0.25 * Double(totalNumberOfTilesOnScreen()))
        }
        var currentGameState: GameState
        var totalNumberOfTilesRevealed: Int
        var currentScoreValue: Int
        var isRevealing: Bool

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
        var topHeaderViewModel = TopHeaderView.ViewModel(score: viewModel.currentScoreValue, gridSize: viewModel.totalTilesInRow, isRevealing: true)

        topHeaderViewModel.changeGridSizeButtonActionClosure = { [weak self] newGridSize in
            self?.viewModel.totalTilesInRow = newGridSize
        }

        topHeaderViewModel.resetButtonActionClosure = { [weak self] in
            self?.resetGame()
        }

        topHeaderViewModel.revealButtonActionClosure = { [weak self] toShow in
            self?.toggleMinesDisplayState(toShow: toShow)
        }
        return topHeaderViewModel
    }

    func toggleMinesDisplayState(toShow: Bool) {
        self.viewModel.isRevealing = !self.viewModel.isRevealing
        minesButtonsHolder.forEach { $0.toggleMineVisibility(toShow: toShow) }
        topHeaderView.updateRevealStatus(value: self.viewModel.isRevealing)
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
        gridHolderView.layer.cornerRadius = Constants.gridCornerRadius
        gridHolderView.layer.borderWidth = Constants.gridWidth
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

                let tileButton = MineButton(position: CGPoint(x: xPosition, y: yPosition), dimension: CGFloat(viewModel.tileWidth), isMine: doesMineExistForTile, sequenceNumber: buttonSequenceNumber, numberOfSurroundingMines: totalNumberOfMinesSurroundingGivenTile, sequenceOfSurroundingTiles: NeighboringTilesProvider.neighboringTilesForGivenMineTile(with: buttonSequenceNumber, totalNumberOfTilesInRow: viewModel.totalTilesInRow))

                tileButton.gameOverClosure = { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.updateGameState()
                    strongSelf.showAllMines()
                    strongSelf.showAlert(with: "You clicked on mine and now game is over", completion: {
                        strongSelf.resetGame()
                    })
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

        let parentContentView = UIView()
        parentContentView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(parentContentView)
        self.view.addSubview(topHeaderView)

        let viewsDictionary = ["gridHolderView": gridHolderView, "topHeaderView": topHeaderView!, "parentContentView": parentContentView]
        let metrics = ["totalGridViewHeight": totalGridViewHeight]

        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[parentContentView]|", options: [], metrics: metrics, views: viewsDictionary))
        NSLayoutConstraint.activate([
            topHeaderView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16.0),
            topHeaderView.heightAnchor.constraint(equalToConstant: 44.0),
            topHeaderView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 8.0),
            topHeaderView.widthAnchor.constraint(greaterThanOrEqualToConstant: 0.0)
            ])
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[topHeaderView]-[parentContentView]-|", options: [], metrics: metrics, views: viewsDictionary))


        let scrollViewAutoLayout = ScrollViewAutolayoutCreator(parentView: parentContentView)
        scrollViewAutoLayout.contentView.addSubview(gridHolderView)

        //TODO: Replace it with Anchor constraints

        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[gridHolderView(totalGridViewHeight)]-20-|", options: [], metrics: metrics, views: viewsDictionary))

        if CGFloat(totalGridViewHeight) > self.view.frame.width {
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[gridHolderView(totalGridViewHeight)]-44-|", options: [], metrics: metrics, views: viewsDictionary))
        } else {
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[gridHolderView(totalGridViewHeight)]-44-|", options: [], metrics: metrics, views: viewsDictionary))
        }
    }

    @objc func longPressGesturePressHandler(with gesture: UIGestureRecognizer) {
        guard gesture.state == .ended, let tileButton = gesture.view as? MineButton else { return }
        tileButton.updateStateWithQuestionMark()
    }

    func highlightNeighboringButtons(with sequenceNumber: Int) {
        guard let mineButton = regularButtonsHolder.first(where: { $0.stateViewModel.sequenceNumber == sequenceNumber }) else { return }

        if !mineButton.stateViewModel.isVisited {
            
            viewModel.totalNumberOfTilesRevealed = viewModel.totalNumberOfTilesRevealed + 1
            mineButton.stateViewModel.isVisited = true            
            mineButton.updateAppearance()

            if mineButton.stateViewModel.numberOfSurroundingMines == 0 {
                viewModel.currentScoreValue = viewModel.currentScoreValue + 1
                mineButton.stateViewModel.sequenceOfSurroundingTiles.forEach { self.highlightNeighboringButtons(with: $0) }
            } else {
                mineButton.setTitle("\(mineButton.stateViewModel.numberOfSurroundingMines)", for: .normal)
                viewModel.currentScoreValue = viewModel.currentScoreValue + (1 * mineButton.stateViewModel.numberOfSurroundingMines)
            }

            topHeaderView.updateScore(value: self.viewModel.currentScoreValue)

            if self.viewModel.didUserWinCurrentGame() {
                self.showAlert(with: "You've won the game", completion: { [weak self] in
                    self?.resetGame()
                })
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
                self.populateNumberOfSurroundingMinesForTile(with: generateRandomMinesSequence)
                minesLocationHolder[generateRandomMinesSequence] = true
            }
        }
    }

    func populateNumberOfSurroundingMinesForTile(with minesTileSequenceNumber: Int) {
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
        minesButtonsHolder.forEach { $0.showImage(with: ImageNames.skull) }
    }

    func showAlert(with message: String, completion: @escaping () -> Void) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
}

extension GameHomePageViewController {
    func resetGame() {
        minesLocationHolder.removeAll()
        numberOfSurroundingMinesHolder.removeAll()
        minesButtonsHolder.removeAll()
        regularButtonsHolder.removeAll()

        resetViewModel()
        resetConstraints()
        createNewGridOnScreen()
        topHeaderView.updateScore(value: self.viewModel.currentScoreValue)
        topHeaderView.updateGridSize(value: self.viewModel.totalTilesInRow)
    }

    func resetViewModel() {
        self.viewModel.currentGameState = .notStarted
        self.viewModel.totalNumberOfTilesRevealed = 0
        self.viewModel.currentScoreValue = 0
        self.viewModel.isRevealing = true
        topHeaderView.updateRevealStatus(value: self.viewModel.isRevealing)
    }

    func resetConstraints() {
        gridHolderView.subviews.forEach { $0.removeFromSuperview() }
        gridHolderView.removeFromSuperview()
        topHeaderView.removeFromSuperview()
    }
}
