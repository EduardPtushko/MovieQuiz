//
//  ArrayTests.swift
//  MovieQuiz
//
//  Created by Eduard Ptushko on 09.07.2026.
//

import XCTest
@testable import MovieQuiz

final class ArrayTests: XCTestCase {
    func testGetValueInRange() throws {
        // Given
        let array = [1, 2, 3, 4, 5]

        // When
        let value = array[safe: 2]

        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 3)
    }

    func testGetValueOutOfRange() throws {
        // Given
        let array = [1, 2, 3, 4, 5]

        // When
        let value = array[safe: 5]

        // Then
        XCTAssertNil(value)
    }
}
