import UIKit

private struct QuizStepViewModel {
  let image: UIImage
  let question: String
  let questionNumber: String
}

private struct QuizQuestion {
  let image: String
  let text: String
  let correctAnswer: Bool
}

private struct QuizResultsViewModel {
  let title: String
  let text: String
  let buttonText: String
}

private let questions: [QuizQuestion] = [
    QuizQuestion(
        image: "The Godfather",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: true),
    QuizQuestion(
        image: "The Dark Knight",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: true),
    QuizQuestion(
        image: "Kill Bill",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: true),
    QuizQuestion(
        image: "The Avengers",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: true),
    QuizQuestion(
        image: "Deadpool",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: true),
    QuizQuestion(
        image: "The Green Knight",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: true),
    QuizQuestion(
        image: "Old",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: false),
    QuizQuestion(
        image: "The Ice Age Adventures of Buck Wild",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: false),
    QuizQuestion(
        image: "Tesla",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: false),
    QuizQuestion(
        image: "Vivarium",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: false)
]
private var currentQuestionIndex = 0
private var correctAnswers = 0


final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var posterImage: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentQuestion = questions[currentQuestionIndex]
        show(quiz: convert(model: currentQuestion))
    }
    
    
    @IBAction private func yesButtonTapped() {
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonTapped() {
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        posterImage.layer.borderWidth = 0
        posterImage.image = step.image
        questionLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(title: result.title,
                                      message: result.text,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            correctAnswers = 0
            currentQuestionIndex = 0
            
            self.viewDidLoad()
        }

        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(), question: model.text, questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        posterImage.layer.masksToBounds = true
        posterImage.layer.borderWidth = 8
        posterImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
           self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            let result = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш рекорд: \(correctAnswers)/\(questions.count)",
                buttonText: "Сыграть еще раз"
            )
            show(quiz: result)
        } else {
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            
            show(quiz: viewModel)
        }
    }
}
