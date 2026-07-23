//
//  MovieQuizPresenterTests.swift
//  MovieQuizTests
//
//  Created by Eduard Ptushko on 14.07.2026.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        // Given
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question =  QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        
        // When
        let viewModel = sut.convert(model: question)
        
        // Then
        XCTAssertEqual(viewModel.image, emptyData)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
