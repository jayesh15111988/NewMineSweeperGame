//
//  MineButton.swift
//  NewMineSweeperGame
//
//  Created by Jayesh Kawli on 1/1/19.
//  Copyright © 2019 Jayesh Kawli. All rights reserved.
//

import UIKit

class MineButton: UIButton {

    enum MineButtonstate {
        case selected
        case notSelected
        case questionMark
        case revealed

        func color() -> UIColor {
            switch self {
            case .selected:
                return .blue
            case .notSelected:
                return .red
            case .questionMark:
                return .white
            case .revealed:
                return .green
            }
        }
    }

    struct StateViewModel {
        let isMine: Bool
        var state: MineButtonstate
        let numberOfSurroundingMines: Int
        var sequenceOfSurroundingTiles: [Int]
        var isVisited: Bool {
            didSet {
                if isVisited {
                    self.state = .selected
                }
            }
        }
    }

    let sequenceNumber: Int
    let numberOfSurroundingMines: Int
    var stateViewModel: StateViewModel
    var tileSelectedClosure: ((Int) -> Void)?
    var gameOverClosure: (() -> Void)?
    let overlayImageView = UIImageView(frame: .zero)

    init(position: CGPoint, dimension: CGFloat, isMine: Bool, sequenceNumber: Int, numberOfSurroundingMines: Int) {
        self.sequenceNumber = sequenceNumber
        self.numberOfSurroundingMines = numberOfSurroundingMines

        self.stateViewModel = StateViewModel(isMine: isMine, state: .notSelected, numberOfSurroundingMines: numberOfSurroundingMines, sequenceOfSurroundingTiles: [], isVisited: false)

        super.init(frame: CGRect(x: position.x, y: position.y, width: dimension, height: dimension))
        self.configureButton(with: numberOfSurroundingMines)
        self.configureOverlayImageView(with: dimension)
        self.updateBackgroundColor()
    }

    func configureOverlayImageView(with dimension: CGFloat) {
        self.addSubview(self.overlayImageView)
        self.overlayImageView.frame = CGRect(x: 0, y: 0, width: dimension, height: dimension)
        self.overlayImageView.alpha = 0.0
        self.overlayImageView.image = UIImage(named: "skull")
    }

    func configureButton(with numberOfNeighboringMines: Int) {
        let titleColor: UIColor

        if stateViewModel.state == .questionMark {
            titleColor = .orange
        } else {
            if numberOfSurroundingMines == 1 {
                titleColor = .white
            } else if numberOfNeighboringMines < 4 {
                titleColor = .orange
            } else {
                titleColor = .red
            }
        }

        self.setTitleColor(titleColor, for: .normal)
        self.addTarget(self, action: #selector(tileButtonSelected), for: .touchUpInside)
    }

    @objc func tileButtonSelected() {
        if stateViewModel.state != .selected {
            stateViewModel.state = .selected
            if stateViewModel.isMine {
                self.gameOverClosure?()
            } else {
                self.tileSelectedClosure?(sequenceNumber)
            }
        }
    }

    func showImage(with imageName: String) {
        self.overlayImageView.image = UIImage(named: imageName)
        self.overlayImageView.alpha = 1.0
    }

    func hideImage() {
        self.overlayImageView.image = nil
        self.overlayImageView.alpha = 0.0
    }

    func updateBackgroundColor() {
        self.backgroundColor = self.stateViewModel.state.color()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
