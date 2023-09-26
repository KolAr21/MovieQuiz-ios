import UIKit


final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var posterImage: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    
    var result: AlertModel? //
    var alertResult: AlertPresenterProtocol? //
    private var alertPresenter: AlertPresenterProtocol?
    
    private var presenter: MovieQuizPresenter!
    
    var statistic: StatisticService? //
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        counterLabel.accessibilityIdentifier = "Index"
        
        presenter = MovieQuizPresenter(viewController: self)
        
        titleLabel.font = UIFont.medium(with: 20)
        counterLabel.font = UIFont.medium(with: 20)
        questionLabel.font = UIFont.bold(with: 23)
        noButton.titleLabel?.font = UIFont.medium(with: 20)
        yesButton.titleLabel?.font = UIFont.medium(with: 20)
        
        posterImage.clipsToBounds = true
        posterImage.layer.cornerRadius = 20
        
        //questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertResult = AlertPresenter(delegate: self)
        alertPresenter = AlertPresenter(delegate: self)
        statistic = StatisticServiceImplementation()
        
        activityIndicator.hidesWhenStopped = true
        showLoadingIndicator()
        //questionFactory?.loadData()
        //questionFactory?.requestNextQuestion()
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonTapped() {
        presenter.yesButtonTapped()
    }
    
    @IBAction private func noButtonTapped() {
        presenter.noButtonTapped()
    }
    
    // MARK: - Private functions
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self  = self else { return }
            self.activityIndicator.stopAnimating()
            let alert = AlertModel(
                title: "Ошибка",
                message: message,
                buttonText: "Попробовать еще раз") {
                self.presenter.restartGame()
                //self.questionFactory?.loadData()
            }
            self.alertPresenter?.show(alertModel: alert)
        }
    }
    
    func show(quiz step: QuizStepViewModel) {
        posterImage.layer.borderWidth = 0
        posterImage.image = step.image
        questionLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func showAnswerResult(isCorrect: Bool) {
        switchButton(is: false)
        
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        
        posterImage.layer.borderWidth = 8
        posterImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.switchButton(is: true)
            presenter.showNextQuestionOrResults()
        }
    }
    
    func createAlertModel() -> AlertModel {
        return AlertModel(title: "Этот раунд окончен!", message: createAlertMessage(), buttonText: "Сыграть еще раз") {
            self.presenter.restartGame()
            //self.questionFactory?.requestNextQuestion()
        }
    }
    
    private func createAlertMessage() -> String {
        guard let statistic = statistic else { return "" }
        
        let currentResultGame = "Ваш результат: \(presenter.correctAnswers)/\(presenter.questionsAmount)"
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
}
