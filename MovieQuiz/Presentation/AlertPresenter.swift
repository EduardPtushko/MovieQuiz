//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Eduard Ptushko on 15.06.2026.
//

import UIKit

final class AlertPresenter {

    func show(in vc: UIViewController, model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        alert.view.accessibilityIdentifier = "Alert"

        let action = UIAlertAction(title: model.buttonText, style: .default) {
            _ in
            model.completion()
        }

        alert.addAction(action)

        vc.present(alert, animated: true)
    }
}
