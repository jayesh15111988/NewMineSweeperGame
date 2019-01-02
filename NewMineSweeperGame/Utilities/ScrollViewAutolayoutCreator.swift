//
//  ScrollViewAutolayoutCreator.swift
//  NewMineSweeperGame
//
//  Created by Jayesh Kawli on 1/1/19.
//  Copyright © 2019 Jayesh Kawli. All rights reserved.
//

import UIKit

class ScrollViewAutolayoutCreator {

    let scrollView: UIScrollView
    let contentView: UIView

    init(parentView: UIView) {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false

        parentView.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.constrainFromAllSidesTo(parentView: parentView)
        contentView.constrainFromAllSidesTo(parentView: scrollView)
    }
}
