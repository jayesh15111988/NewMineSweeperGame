//
//  NeighboringTilesProviderTests.swift
//  NewMineSweeperGameTests
//
//  Created by Jayesh Kawli on 1/6/19.
//  Copyright © 2019 Jayesh Kawli. All rights reserved.
//

import XCTest
@testable import NewMineSweeperGame

class NeighboringTilesProviderTests: XCTestCase {
    func testThatCorrectNumberOfNeighboringTilesAreReturnedForCorners() {
        let topLeftCornerNeighbors = NeighboringTilesProvider.neighboringTilesForGivenMineTile(with: 0, totalNumberOfTilesInRow: 3)

        XCTAssertEqual(topLeftCornerNeighbors, [1, 3, 4])

        let bottomRightCornerNeighbors = NeighboringTilesProvider.neighboringTilesForGivenMineTile(with: 8, totalNumberOfTilesInRow: 3)
        XCTAssertEqual(bottomRightCornerNeighbors, [4, 5, 7])
    }

    func testThatCorrectNumberOfNeighboringTilesAreReturnedForEdges() {
        let leftEdgeNeighbors = NeighboringTilesProvider.neighboringTilesForGivenMineTile(with: 3, totalNumberOfTilesInRow: 3)

        XCTAssertEqual(leftEdgeNeighbors, [0, 1, 4, 6, 7])

        let rightEdgeNeighbors = NeighboringTilesProvider.neighboringTilesForGivenMineTile(with: 5, totalNumberOfTilesInRow: 3)
        XCTAssertEqual(rightEdgeNeighbors, [1, 2, 4, 7, 8])
    }

    func testThatCorrectNumberOfNeighboringTilesAreReturnedForInnerTile() {
        let innerMostNeighbors = NeighboringTilesProvider.neighboringTilesForGivenMineTile(with: 4, totalNumberOfTilesInRow: 3)

        XCTAssertEqual(innerMostNeighbors, [0, 1, 2, 3, 5, 6, 7, 8])
    }
}
