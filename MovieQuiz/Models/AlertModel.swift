//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Eduard Ptushko on 15.06.2026.
//

import Foundation

/// Модель для отображения алерта.
struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
