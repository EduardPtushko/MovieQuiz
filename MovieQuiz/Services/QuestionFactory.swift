//
//  QuestionFabric 2.swift
//  MovieQuiz
//
//  Created by Eduard Ptushko on 05.06.2026.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {

    // MARK: - Properties

    private var movies: [MostPopularMovie] = []
    private let moviesLoader: MoviesLoadingProtocol

    private weak var delegate: QuestionFactoryDelegate?

    // MARK: - Init

    init(
        moviesLoader: MoviesLoadingProtocol,
        delegate: QuestionFactoryDelegate? = nil
    ) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }

    // MARK: - Public Methods

    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            let index = (0..<movies.count).randomElement() ?? 0

            guard let movie = self.movies[safe: index] else { return }

            var imageData = Data()

            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
            }

            let rating = Float(movie.rating ?? "0") ?? 0
            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7

            let question = QuizQuestion(
                image: imageData,
                text: text,
                correctAnswer: correctAnswer
            )

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }

    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
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
}
