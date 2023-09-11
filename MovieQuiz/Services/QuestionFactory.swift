//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Арина Колганова on 25.08.2023.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
//
//    private let questions: [QuizQuestion] = [
//        QuizQuestion(
//            image: "The Godfather",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Dark Knight",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Kill Bill",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Avengers",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Deadpool",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Green Knight",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Old",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "The Ice Age Adventures of Buck Wild",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "Tesla",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "Vivarium",
//            correctAnswer: false)
//    ]
    
    private let moviesLoader: MoviesLoading
    weak var delegate: QuestionFactoryDelegate?
    
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
           
           do {
               imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
                self.delegate?.didFailToLoadData(with: error)
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let randomRating = Int.random(in: 7...9)
            
            let text = "Рейтинг этого фильма больше чем \(randomRating)?"
            let correctAnswer = rating > Float(randomRating)
            
            let question = QuizQuestion(image: imageData,
                                         text: text,
                                         correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
