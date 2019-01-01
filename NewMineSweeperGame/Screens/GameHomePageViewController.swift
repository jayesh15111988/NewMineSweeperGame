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

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "Blasting Minesweeper"
        layoutCustomViews()
        configureCustomViews()
    }
}

extension GameHomePageViewController: ViewsCustomizable {
    func layoutCustomViews() {

        let topHeaderView = TopHeaderView(viewModel: headerViewModel())
        self.view.addSubview(topHeaderView)

        NSLayoutConstraint.activate([
            topHeaderView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            topHeaderView.heightAnchor.constraint(equalToConstant: Constants.defaultViewHeight),
            topHeaderView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            topHeaderView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            ])
    }

    func configureCustomViews() {

    }

    private func headerViewModel() -> TopHeaderView.ViewModel {
        var topHeaderViewModel = TopHeaderView.ViewModel(score: 0, gridSize: 3, isRevealing: true)

        topHeaderViewModel.changeGridSizeButtonActionClosure = { [weak self] newGridSize in
            print(self.debugDescription)
        }

        topHeaderViewModel.resetButtonActionClosure = { [weak self] in
            print(self.debugDescription)
        }

        topHeaderViewModel.revealButtonActionClosure = { [weak self] isRevealing in
            print(self.debugDescription)
        }
        return topHeaderViewModel
    }
}
