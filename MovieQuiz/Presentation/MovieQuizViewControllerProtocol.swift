//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Eduard Ptushko on 14.07.2026.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)

    var isAnswerButtonsEnabled: Bool { get set }
}
