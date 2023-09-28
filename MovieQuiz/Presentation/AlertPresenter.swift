//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Арина Колганова on 26.08.2023.
//

import UIKit

protocol  AlertPresenterProtocol {
    func show(alertModel: AlertModel)
}

final class AlertPresenter: AlertPresenterProtocol {
    
    weak var delegate: MovieQuizViewController?
    
    init(delegate: MovieQuizViewController) {
        self.delegate = delegate
    }
        
    func show(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        let action = UIAlertAction(
            title: alertModel.buttonText,
            style: .default) { _ in
            alertModel.completion()
        }
    
        alert.view.accessibilityIdentifier = "Alert"
        alert.addAction(action)
        delegate?.present(alert, animated: true, completion: nil)
    }
}
