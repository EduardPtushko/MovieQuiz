//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Eduard Ptushko on 14.07.2026.
//

import Foundation

final class MovieQuizPresenter {

    // MARK: - Properties

    private weak var viewController: MovieQuizViewControllerProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol!

    private var currentQuestion: QuizQuestion?
    private let questionsAmount: Int = 10
    private var correctAnswers: Int = 0
    private var currentQuestionIndex: Int = 0

    // MARK: - Init

    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        statisticService = StatisticService()
        setupQuestionFactory()
    }

    // MARK: - Public Methods

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: model.image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }

    func showNextQuestionOrResults() {
        if isLastQuestion() {
            statisticService.store(
                correct: correctAnswers,
                total: questionsAmount
            )

            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: makeQuizResultText(),
                buttonText: "Сыграть еще раз"
            )

            viewController?.show(quiz: viewModel)
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }

    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }

        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        viewController?.isAnswerButtonsEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }

            self.questionFactory = self.questionFactory
            self.showNextQuestionOrResults()
            viewController?.isAnswerButtonsEnabled = true
        }
    }

    func makeQuizResultText() -> String {
        "Ваш результат: \(correctAnswers)/\(questionsAmount)\nКоличество сыгранных квизов: \(statisticService.gamesCount)\nРекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))\nСредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
    }

    func yesButtonTapped() {
        checkAnswer(true)
    }

    func noButtonTapped() {
        checkAnswer(false)
    }

    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }

    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    func restartGame() {
        resetQuestionIndex()
        correctAnswers = 0
        self.questionFactory?.requestNextQuestion()
    }

    // MARK: - Private Methods

    private func setupQuestionFactory() {
        questionFactory = QuestionFactory(
            moviesLoader: MoviesLoader(),
            delegate: self
        )

        viewController?.showLoadingIndicator()
        questionFactory?.loadData()
    }

    private func checkAnswer(_ givenAnswer: Bool) {
        guard let currentQuestion else { return }

        showAnswerResult(
            isCorrect: currentQuestion.correctAnswer == givenAnswer
        )
    }
}

// MARK: - QuestionFactoryDelegate

extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }

        currentQuestion = question
        let viewModel = convert(model: question)

        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
}
