//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Eduard Ptushko on 16.06.2026.
//

import Foundation

/// Сервис для сбора, подсчета и сохранения статистики игровых сессий.
final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard

    /// Общее количество правильных ответов
    private var totalCorrectAnswers: Int {
        get {
            storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }

    /// Общее количество заданных вопросов
    private var totalQuestionsAsked: Int {
        get {
            storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalQuestionsAsked.rawValue)
        }
    }

    /// Количество игр
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }

    /// Результаты лучшей игры
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

    /// Средняя точность ответов пользователя в процентах.
    var totalAccuracy: Double {
        guard totalQuestionsAsked > 0 else { return 0.0 }
        return (Double(totalCorrectAnswers) / Double(totalQuestionsAsked)) * 100
    }

    /// Метод для сохранения результатов квиза
    func store(correct count: Int, total amount: Int) {
        totalCorrectAnswers = totalCorrectAnswers + count
        totalQuestionsAsked = totalQuestionsAsked + amount
        gamesCount = gamesCount + 1

        let gameResult = GameResult(correct: count, total: amount, date: Date())
        if gameResult.isBetterThan(bestGame) {
            bestGame = gameResult
        }

    }

    private enum Keys: String {
        case gamesCount  // Для счётчика сыгранных игр
        case bestGameCorrect  // Для количества правильных ответов в лучшей игре
        case bestGameTotal  // Для общего количества вопросов в лучшей игре
        case bestGameDate  // Для даты лучшей игры
        case totalCorrectAnswers  // Для общего количества правильных ответов за все игры
        case totalQuestionsAsked  // Для общего количества вопросов, заданных за все игры
    }

}
