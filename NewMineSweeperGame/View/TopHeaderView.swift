//
//  TopHeaderView.swift
//  NewMineSweeperGame
//
//  Created by Jayesh Kawli on 1/1/19.
//  Copyright © 2019 Jayesh Kawli. All rights reserved.
//

import UIKit


protocol ViewsCustomizable {
    func layoutCustomViews()
    func configureCustomViews()
}

class TopHeaderView: UIView {

    struct ViewModel {
        var score: Int
        var gridSize: Int
        var isRevealing: Bool

        var resetButtonActionClosure: (() -> Void)?
        var revealButtonActionClosure: ((Bool) -> Void)?
        var changeGridSizeButtonActionClosure: ((Int) -> Void)?

        init(score: Int, gridSize: Int, isRevealing: Bool) {
            self.score = score
            self.gridSize = gridSize
            self.isRevealing = isRevealing
        }
    }

    enum Constants {
        static let horizontalPadding: CGFloat = 10.0
        static let verticalPadding: CGFloat = 8.0
        static let defaultFieldWidth: CGFloat = 50.0
        static let defaultViewHeight: CGFloat = 50.0
        static let verticalCenterOffset: CGFloat = 1.0
    }

    let scoreLabel = UILabel(frame: .zero)
    let gridSizeInputField = UITextField(frame: .zero)
    let resetButton = UIButton(frame: .zero)
    let revealButton = UIButton(frame: .zero)

    var viewModel: TopHeaderView.ViewModel

    init(viewModel: TopHeaderView.ViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .lightGray
        self.layoutCustomViews()
        self.configureCustomViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension TopHeaderView {
    func updateScore(score: Int) {
        self.scoreLabel.text = "Score: \(score)"
    }
}

extension TopHeaderView {
    @objc func gridSizeChanged() {
        if let inputText = gridSizeInputField.text, let gridSize = Int(inputText) {
            self.gridSizeInputField.resignFirstResponder()
            self.viewModel.gridSize = gridSize
            self.viewModel.changeGridSizeButtonActionClosure?(gridSize)
        }
    }

    @objc func resetButtonPressed() {
        resetViewsState()
        self.viewModel.resetButtonActionClosure?()
    }

    func resetViewsState() {
        self.scoreLabel.text = "Score: 0"
        self.gridSizeInputField.text = String(viewModel.gridSize)
    }

    @objc func revealButtonPressed() {
        self.viewModel.revealButtonActionClosure?(self.viewModel.isRevealing)
        self.viewModel.isRevealing = !self.viewModel.isRevealing
    }
}

extension TopHeaderView: ViewsCustomizable {
    func layoutCustomViews() {
        self.addSubview(scoreLabel)
        self.addSubview(gridSizeInputField)
        self.addSubview(resetButton)
        self.addSubview(revealButton)

        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        gridSizeInputField.translatesAutoresizingMaskIntoConstraints = false
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        revealButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.scoreLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.horizontalPadding),
            self.gridSizeInputField.leadingAnchor.constraint(equalTo: self.scoreLabel.trailingAnchor, constant: Constants.horizontalPadding),
            self.resetButton.leadingAnchor.constraint(equalTo: self.gridSizeInputField.trailingAnchor, constant: Constants.horizontalPadding),
            self.revealButton.leadingAnchor.constraint(equalTo: self.resetButton.trailingAnchor, constant: Constants.horizontalPadding),
            self.revealButton.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -Constants.horizontalPadding),

            self.scoreLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: TopHeaderView.Constants.defaultFieldWidth),
            self.gridSizeInputField.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.defaultFieldWidth),
            self.resetButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.defaultFieldWidth),
            self.revealButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.defaultFieldWidth),
            gridSizeInputField.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: Constants.verticalCenterOffset)
            ])

        scoreLabel.verticallyConstrainTo(parentView: self, padding: Constants.verticalPadding)
        resetButton.verticallyConstrainTo(parentView: self, padding: Constants.verticalPadding)
        revealButton.verticallyConstrainTo(parentView: self, padding: Constants.verticalPadding)
    }

    func configureCustomViews() {
        self.scoreLabel.text = "Score: 0"
        self.scoreLabel.textAlignment = .left

        let toolbar = UIToolbar(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.frame.width, height: Constants.defaultViewHeight)))
        var toolbarItems: [UIBarButtonItem] = []
        toolbarItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        toolbarItems.append(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(gridSizeChanged)))
        toolbar.items = toolbarItems
        gridSizeInputField.text = String(self.viewModel.gridSize)
        gridSizeInputField.inputAccessoryView = toolbar
        gridSizeInputField.autocorrectionType = .no
        gridSizeInputField.keyboardType = .numberPad

        resetButton.setTitle("Reset", for: .normal)
        resetButton.addTarget(self, action: #selector(resetButtonPressed), for: .touchUpInside)

        revealButton.setTitle("Reveal", for: .normal)
        revealButton.addTarget(self, action: #selector(revealButtonPressed), for: .touchUpInside)
    }
}
