//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Eduard Ptushko on 16.06.2026.
//

import Foundation

final class StatisticService: StatisticServiceProtocol {

    // MARK: - Nested Types

    private enum Keys: String {
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case totalCorrectAnswers
        case totalQuestionsAsked
    }

    // MARK: - Dependencies

    private let storage: UserDefaults = .standard

    // MARK: - Private Properties

    private var totalCorrectAnswers: Int {
        get {
            storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }

    private var totalQuestionsAsked: Int {
        get {
            storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalQuestionsAsked.rawValue)
        }
    }

    // MARK: - Public Properties

    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }

    var bestGame: GameResult {
        get {
            let gameResultDate =
                storage.object(forKey: Keys.bestGameDate.rawValue) as? Date
                ?? Date()
            let gameResultCorrect = storage.integer(
                forKey: Keys.bestGameCorrect.rawValue
            )
            let gameResultTotal = storage.integer(
                forKey: Keys.bestGameTotal.rawValue
            )

            return GameResult(
                correct: gameResultCorrect,
                total: gameResultTotal,
                date: gameResultDate
            )
        }
        set {
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
        }
    }

    var totalAccuracy: Double {
        guard totalQuestionsAsked > 0 else { return 0.0 }
        return (Double(totalCorrectAnswers) / Double(totalQuestionsAsked)) * 100
    }

    // MARK: - Public Methods

    func store(correct count: Int, total amount: Int) {
        totalCorrectAnswers = totalCorrectAnswers + count
        totalQuestionsAsked = totalQuestionsAsked + amount
        gamesCount = gamesCount + 1

        let gameResult = GameResult(correct: count, total: amount, date: Date())
        if gameResult.isBetterThan(bestGame) {
            bestGame = gameResult
        }

    }
}
