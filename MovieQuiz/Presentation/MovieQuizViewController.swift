import UIKit


final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Lifecycle
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var posterImage: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var result: AlertModel?
    private var alertResult: AlertPresenterProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    
    private var presenter = MovieQuizPresenter()
    
    private var statistic: StatisticService?
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    private var correctAnswers = 0
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        counterLabel.accessibilityIdentifier = "Index"
        
        titleLabel.font = UIFont.medium(with: 20)
        counterLabel.font = UIFont.medium(with: 20)
        questionLabel.font = UIFont.bold(with: 23)
        noButton.titleLabel?.font = UIFont.medium(with: 20)
        yesButton.titleLabel?.font = UIFont.medium(with: 20)
        
        posterImage.clipsToBounds = true
        posterImage.layer.cornerRadius = 20
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertResult = AlertPresenter(delegate: self)
        alertPresenter = AlertPresenter(delegate: self)
        statistic = StatisticServiceImplementation()
        
        activityIndicator.hidesWhenStopped = true
        showLoadingIndicator()
        questionFactory?.loadData()
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonTapped() {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonTapped() {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    // MARK: - Private functions
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    private func showNetworkError(message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self  = self else { return }
            self.activityIndicator.stopAnimating()
            let alert = AlertModel(
                title: "Ошибка",
                message: message,
                buttonText: "Попробовать еще раз") {
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                self.questionFactory?.loadData()
            }
            self.alertPresenter?.show(alertModel: alert)
        }
    }
    
    private func show(quiz step: QuizStepViewModel) {
        posterImage.layer.borderWidth = 0
        posterImage.image = step.image
        questionLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        switchButton(is: false)
        
        if isCorrect {
            correctAnswers += 1
        }
        
        posterImage.layer.borderWidth = 8
        posterImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.switchButton(is: true)
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            statistic?.store(correct: correctAnswers, total: presenter.questionsAmount)
            result = createAlertModel()
            guard let result = result else { return }
            alertResult?.show(alertModel: result)
        } else {
            presenter.switchToNextIndex()
            
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    private func createAlertModel() -> AlertModel {
        return AlertModel(title: "Этот раунд окончен!", message: createAlertMessage(), buttonText: "Сыграть еще раз") {
            self.correctAnswers = 0
            self.presenter.resetQuestionIndex()
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    private func createAlertMessage() -> String {
        guard let statistic = statistic else { return "" }
        
        let currentResultGame = "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)"
        let totalCountGame = "Количество сыгранных квизов: \(statistic.gamesCount)"
        let totalRecordGame = "Рекорд: \(statistic.bestGame.correct)/\(statistic.bestGame.total) (\(statistic.bestGame.date.dateTimeString))"
        let totalAccuracyGame = "Средняя точность: \(String(format: "%.2f", statistic.totalAccuracy))%"
        
        let message: [String] = [currentResultGame, totalCountGame, totalRecordGame, totalAccuracyGame]
        
        return message.joined(separator: "\n")
        
    }
    
    
    private func switchButton(is enabled: Bool) {
        yesButton.isEnabled = enabled
        noButton.isEnabled = enabled
    }
    
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        activityIndicator.stopAnimating()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
}
