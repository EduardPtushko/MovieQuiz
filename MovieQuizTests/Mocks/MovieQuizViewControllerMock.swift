//
//  MovieQuizViewControllerMock.swift
//  MovieQuizTests
//
//  Created by Eduard Ptushko on 14.07.2026.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    var isAnswerButtonsEnabled: Bool = false
    
    var showLoadingIndicatorCallsCount = 0
    var hideLoadingIndicatorCallsCount = 0
    var showNetworkErrorCallsCount = 0


    func show(quiz step: QuizStepViewModel) {

    }

    func show(quiz result: QuizResultsViewModel) {

    }

    func highlightImageBorder(isCorrectAnswer: Bool) {

    }

    func showLoadingIndicator() {
        showLoadingIndicatorCallsCount += 1
    }

    func hideLoadingIndicator() {
        hideLoadingIndicatorCallsCount += 1
    }

    func showNetworkError(message: String) {
        showNetworkErrorCallsCount += 1
    }
}
