//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Арина Колганова on 26.08.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
