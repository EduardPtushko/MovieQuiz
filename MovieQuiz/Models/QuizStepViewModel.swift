//
//  QuizStepViewModel.swift
//  MovieQuiz
//
//  Created by Eduard Ptushko on 03.06.2026.
//

import UIKit

/// Модель для отображения  вопроса на экране.
struct QuizStepViewModel {
    /// Бинарные данные изображения афиши фильма.
    let image: Data
    /// Вопрос о рейтинге квиза.
    let question: String
    /// Прогресс прохождения квиза в текстовом формате.
    let questionNumber: String
}
