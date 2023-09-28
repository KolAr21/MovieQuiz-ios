import UIKit


protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    // MARK: - Lifecycle
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var posterImage: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    private var presenter: MovieQuizPresenter!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        counterLabel.accessibilityIdentifier = "Index"
        
        presenter = MovieQuizPresenter(viewController: self)
        
        setupLabels()
        
        posterImage.clipsToBounds = true
        posterImage.layer.cornerRadius = 20
        
        activityIndicator.hidesWhenStopped = true
        showLoadingIndicator()
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonTapped() {
        presenter.yesButtonTapped()
    }
    
    @IBAction private func noButtonTapped() {
        presenter.noButtonTapped()
    }
    
    // MARK: - Private functions
    
    private func setupLabels() {
        titleLabel.font = UIFont.medium(with: 20)
        counterLabel.font = UIFont.medium(with: 20)
        questionLabel.font = UIFont.bold(with: 23)
        noButton.titleLabel?.font = UIFont.medium(with: 20)
        yesButton.titleLabel?.font = UIFont.medium(with: 20)
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self  = self else { return }
            let alert = UIAlertController(
                title: "Ошибка",
                message: message,
                preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Попробовать ещё раз",
                                       style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.presenter.restartGame()
            }
            self.hideLoadingIndicator()
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let message = presenter?.createAlertMessage()
        let alert = UIAlertController(
            title: result.title,
            message: message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.presenter.restartGame()
        }
        
        alert.addAction(action)
        alert.view.accessibilityIdentifier = "Alert"
        self.present(alert, animated: true, completion: nil)
    }
    
    func show(quiz step: QuizStepViewModel) {
        posterImage.layer.borderWidth = 0
        posterImage.image = step.image
        questionLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        posterImage.layer.borderWidth = 8
        posterImage.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func switchButton(is enabled: Bool) {
        yesButton.isEnabled = enabled
        noButton.isEnabled = enabled
    }
}
