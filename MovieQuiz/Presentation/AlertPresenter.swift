//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Арина Колганова on 26.08.2023.
//

import UIKit

class AlertPresenter: AlertPresenterProtocol {
    
    weak var delegate: MovieQuizViewController?
    //let statistic: StatisticServiceImplementation?
        
    func show(quiz result: AlertModel) {
        let alert = UIAlertController(title: result.title,
                                      message: result.message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            result.completion()
        }
        
        alert.addAction(action)
        delegate?.present(alert, animated: true, completion: nil)
    }
    
    init(delegate: MovieQuizViewController) {
        self.delegate = delegate
    }
}
