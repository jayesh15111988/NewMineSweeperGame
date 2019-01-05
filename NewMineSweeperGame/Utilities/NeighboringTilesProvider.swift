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

        let resultantNeighbors = [Coordinate(row: row - 1, column: col - 1),
                                  Coordinate(row: row - 1, column: col),
                                  Coordinate(row: row - 1, column: col + 1),
                                  Coordinate(row: row, column: col - 1),
                                  Coordinate(row: row, column: col + 1),
                                  Coordinate(row: row + 1, column: col - 1),
                                  Coordinate(row: row + 1, column: col),
                                  Coordinate(row: row + 1, column: col + 1)
            ].filter { $0.isCoordinateInGivenRange(low: 0, high: totalNumberOfTilesInRow - 1) }

        let result = resultantNeighbors.compactMap { value -> Int in
            return value.row * totalNumberOfTilesInRow + value.column
        }

        return result
    }
}

extension Int {
    func isInTheInclusiveRange(low: Int, high: Int) -> Bool {
        return self >= low && self <= high
    }
}

struct Coordinate {
    let row: Int
    let column: Int

    func isCoordinateInGivenRange(low: Int, high: Int) -> Bool {
        return self.row.isInTheInclusiveRange(low: low, high: high) && self.column.isInTheInclusiveRange(low: low, high: high)
    }
}
