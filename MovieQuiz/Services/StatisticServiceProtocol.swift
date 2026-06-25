//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Eduard Ptushko on 16.06.2026.
//

import Foundation

/// Протокол, определяющий интерфейс сервиса игровой статистики.
protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }

    func store(correct count: Int, total amount: Int)
}

/// Модель, представляющая результат одной игровой сессии.
struct GameResult {
    /// Количество правильных ответов, данных пользователем.
    let correct: Int
    /// Общее количество вопросов в пройденной игре.
    let total: Int
    /// Дата и время завершения игровой сессии.
    let date: Date

    /// метод сравнения текущего результата с другим по количеству верных ответов
    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}
