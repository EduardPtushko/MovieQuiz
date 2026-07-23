//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Eduard Ptushko on 11.06.2026.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
