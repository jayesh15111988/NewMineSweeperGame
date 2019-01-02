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
    }

    struct StateViewModel {
        let isMine: Bool
        var state: MineButtonstate
        let numberOfSurroundingMines: Int
        var sequenceOfSurroundingTiles: [Int]
        var isVisited: Bool
    }

    let sequenceNumber: Int
    let numberOfSurroundingMines: Int
    var stateViewModel: StateViewModel
    var tileSelectedClosure: ((Int) -> Void)?
    var gameOverClosure: (() -> Void)?

    init(position: CGPoint, dimension: CGFloat, isMine: Bool, sequenceNumber: Int, numberOfSurroundingMines: Int) {
        self.sequenceNumber = sequenceNumber
        self.numberOfSurroundingMines = numberOfSurroundingMines

        self.stateViewModel = StateViewModel(isMine: isMine, state: .notSelected, numberOfSurroundingMines: numberOfSurroundingMines, sequenceOfSurroundingTiles: [], isVisited: false)




        super.init(frame: CGRect(x: position.x, y: position.y, width: dimension, height: dimension))
        self.configureButton(with: numberOfSurroundingMines)
    }

    func configureButton(with numberOfNeighboringMines: Int) {
        let titleColor: UIColor

        if numberOfSurroundingMines == 1 {
            titleColor = .white
        } else if numberOfNeighboringMines < 4 {
            titleColor = .orange
        } else {
            titleColor = .red
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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
