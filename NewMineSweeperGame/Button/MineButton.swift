//
//  MineButton.swift
//  NewMineSweeperGame
//
//  Created by Jayesh Kawli on 1/1/19.
//  Copyright © 2019 Jayesh Kawli. All rights reserved.
//

import UIKit

enum ImageNames: String {
    case skull
    case mine
}

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
        let sequenceOfSurroundingTiles: [Int]
        let sequenceNumber: Int
        var isVisited: Bool {
            didSet {
                if isVisited {
                    self.state = .selected
                }
            }
        }
    }

    var stateViewModel: StateViewModel
    var tileSelectedClosure: ((Int) -> Void)?
    var gameOverClosure: (() -> Void)?
    let overlayImageView = UIImageView(frame: .zero)

    init(position: CGPoint, dimension: CGFloat, isMine: Bool, sequenceNumber: Int, numberOfSurroundingMines: Int, sequenceOfSurroundingTiles: [Int]) {
        self.stateViewModel = StateViewModel(isMine: isMine, state: .notSelected, numberOfSurroundingMines: numberOfSurroundingMines, sequenceOfSurroundingTiles: sequenceOfSurroundingTiles, sequenceNumber: sequenceNumber, isVisited: false)

        super.init(frame: CGRect(x: position.x, y: position.y, width: dimension, height: dimension))
        self.updateAppearance()
        self.configureOverlayImageView(with: dimension)
    }

    func configureOverlayImageView(with dimension: CGFloat) {
        self.addSubview(self.overlayImageView)
        self.overlayImageView.frame = CGRect(x: 0, y: 0, width: dimension, height: dimension)
        self.overlayImageView.alpha = 0.0
        self.overlayImageView.image = UIImage(named: ImageNames.skull.rawValue)
    }

    @objc func tileButtonSelected() {

        if stateViewModel.isMine {
            self.gameOverClosure?()
            return
        }

        if stateViewModel.state != .selected {
            stateViewModel.state = .selected
            self.tileSelectedClosure?(self.stateViewModel.sequenceNumber)
        }
    }

    func showImage(with imageName: ImageNames) {
        self.overlayImageView.image = UIImage(named: imageName.rawValue)
        self.overlayImageView.alpha = 1.0
    }

    func hideImage() {
        self.overlayImageView.image = nil
        self.overlayImageView.alpha = 0.0
    }

    func updateAppearance() {
        updateBackgroundColor()
        configureButton()
    }

    private func updateBackgroundColor() {
        self.backgroundColor = self.stateViewModel.state.color()
        configureButton()
    }

    private func configureButton() {
        let titleColor: UIColor

        if stateViewModel.state == .questionMark {
            titleColor = .orange
        } else {
            if self.stateViewModel.numberOfSurroundingMines == 1 {
                titleColor = .white
            } else if self.stateViewModel.numberOfSurroundingMines < 4 {
                titleColor = .orange
            } else {
                titleColor = .red
            }
        }

        self.setTitleColor(titleColor, for: .normal)
        self.addTarget(self, action: #selector(tileButtonSelected), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MineButton {
    func toggleMineVisibility(toShow: Bool) {
        if toShow {
            self.stateViewModel.state = .revealed
            self.showImage(with: ImageNames.mine)
        } else {
            self.stateViewModel.state = .notSelected
            self.hideImage()
        }
        self.updateAppearance()
    }

    func updateStateWithQuestionMark() {

        guard self.stateViewModel.state != .selected else { return }

        let currentState = self.stateViewModel.state

        if currentState == .questionMark {
            self.stateViewModel.state = .notSelected
        } else {
            self.stateViewModel.state = .questionMark
        }
        self.updateAppearance()

        if self.stateViewModel.state == .questionMark {
            self.setTitle("?", for: .normal)
        } else {
            self.setTitle("", for: .normal)
        }
    }
}
