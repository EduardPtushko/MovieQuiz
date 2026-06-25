//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Eduard Ptushko on 15.06.2026.
//

import UIKit

/// Класс для отображения системных алертов и уведомлений пользователю.
final class AlertPresenter {

    /// Метод для показа результатов раунда квиза
    /// принимает модель AlertModel и ничего не возвращает
    func show(in vc: UIViewController, model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: model.buttonText, style: .default) {
            _ in
            model.completion()
        }

        alert.addAction(action)

        vc.present(alert, animated: true)
    }
}
