//
//  NeighboringTilesProvider.swift
//  NewMineSweeperGame
//
//  Created by Jayesh Kawli on 1/1/19.
//  Copyright © 2019 Jayesh Kawli. All rights reserved.
//

import Foundation

class NeighboringTilesProvider {
    class func neighboringTilesForGivenMineTile(with minesTileSequenceNumber: Int, totalNumberOfTilesInRow: Int) -> [Int] {

        let row = minesTileSequenceNumber / totalNumberOfTilesInRow
        let col = minesTileSequenceNumber % totalNumberOfTilesInRow

        let resultantNeightbors = [[col - 1, row - 1],
                                            [col, row - 1],
                                            [col + 1, row - 1],
                                            [col - 1, row],
                                            [col + 1, row],
                                            [col - 1, row + 1],
                                            [col, row + 1],
                                            [col + 1, row + 1]
            ].filter { $0.isCoordinateInGivenRange(low: 0, high: totalNumberOfTilesInRow - 1) }

        let result = resultantNeightbors.compactMap { value -> Int in
            return value[1] * totalNumberOfTilesInRow + value[0]
        }

        return result
    }
}

extension Int {
    func isInTheInclusiveRange(low: Int, high: Int) -> Bool {
        return self >= low && self <= high
    }
}

extension Array where Element == Int {
    func isCoordinateInGivenRange(low: Int, high: Int) -> Bool {
        return self[0].isInTheInclusiveRange(low: low, high: high) && self[1].isInTheInclusiveRange(low: low, high: high)
    }
}
