//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Eduard Ptushko on 30.06.2026.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(
        handler: @escaping (Result<MostPopularMovies, Error>) -> Void
    )
}

struct MoviesLoader: MoviesLoading {
    // MARK: - NetworkClient

    private let networkClient = NetworkClient()

    // MARK: - URL

    private var mostPopularMoviesURL: URL {
        guard
            let url = URL(
                string: "https://tv-api.com/en/API/MostPopularMovies/k_zcuw1ytf"
            )
        else {
            preconditionFailure("Unable to construct mostPopularMoviesURL")
        }
        return url
    }

    private var top250MoviesURL: URL {
        guard
            let url = URL(
                string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf"
            )
        else {
            preconditionFailure("Unable to construct mostPopularMoviesURL")
        }
        return url
    }

    func loadMovies(
        handler: @escaping (Result<MostPopularMovies, Error>) -> Void
    ) {
        networkClient.fetch(url: top250MoviesURL) { result in
            switch result {
            case .success(let top250Data):
                networkClient.fetch(url: mostPopularMoviesURL) { result in
                    switch result {
                    case .success(let mostPopularData):
                        do {
                            let decoder = JSONDecoder()
                            let top250Movies = try decoder.decode(
                                MostPopularMovies.self,
                                from: top250Data
                            )
                            let mostPopularMovies = try decoder.decode(
                                MostPopularMovies.self,
                                from: mostPopularData
                            )
                            var combinedMovies = top250Movies.items

                            mostPopularMovies.items.forEach { movie in
                                if !combinedMovies.contains(where: {
                                    $0.title == movie.title
                                }) {
                                    combinedMovies.append(movie)
                                }
                            }
                            let resultMovie = MostPopularMovies(
                                items: combinedMovies,
                                errorMessage: top250Movies.errorMessage
                            )
                            handler(.success(resultMovie))
                        } catch {
                            handler(.failure(error))
                        }
                    case .failure(let error):
                        handler(.failure(error))
                    }
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
