//
//  UIView+Extension.swift
//  NewMineSweeperGame
//
//  Created by Jayesh Kawli on 1/1/19.
//  Copyright © 2019 Jayesh Kawli. All rights reserved.
//

import UIKit

extension UIView {
    func verticallyConstrainTo(parentView: UIView, padding: CGFloat) {
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: parentView.topAnchor, constant: padding),
            self.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -padding)
            ])
    }

    func constrainFromAllSidesTo(parentView: UIView, padding: CGFloat = 0.0) {
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: parentView.topAnchor, constant: padding),
            self.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -padding),
            self.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: padding),
            self.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -padding)
            ])
    }
}
