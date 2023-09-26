//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Арина Колганова on 25.09.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewController?
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticService!
    var statistic: StatisticService?
    
    private var currentQuestionIndex: Int = 0
    let questionsAmount: Int = 10
    var correctAnswers: Int = 0
    
    func yesButtonTapped() {
        didAnswer(isYes: true)
    }
    
    func noButtonTapped() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: isYes == currentQuestion.correctAnswer)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.loadData()
    }
    
    func switchToNextIndex() {
        currentQuestionIndex += 1
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if (isCorrectAnswer) { correctAnswers += 1 }
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func showNextQuestionOrResults() {
        if isLastQuestion() {
            statistic?.store(correct: correctAnswers, total: questionsAmount)
            let text = createAlertMessage()
            let viewModel = QuizResultsViewModel(
                            title: "Этот раунд окончен!",
                            text: text,
                            buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: viewModel)
        } else {
            switchToNextIndex()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func createAlertModel() -> AlertModel {
        return AlertModel(title: "Этот раунд окончен!", message: createAlertMessage(), buttonText: "Сыграть еще раз") {
            self.restartGame()
        }
    }
    
    func showAnswerResult(isCorrect: Bool) {
        viewController?.switchButton(is: false)
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.viewController?.switchButton(is: true)
            self.showNextQuestionOrResults()
        }
    }
    
    func createAlertMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let currentResultGame = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let totalCountGame = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let totalRecordGame = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))"
        let totalAccuracyGame = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let message: [String] = [currentResultGame, totalCountGame, totalRecordGame, totalAccuracyGame]
        
        return message.joined(separator: "\n")
        
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController as? MovieQuizViewController
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
}
