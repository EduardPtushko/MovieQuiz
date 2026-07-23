//
//  Untitled.swift
//  MovieQuiz
//
//  Created by Eduard Ptushko on 30.06.2026.
//

import Foundation

protocol NetworkClientProtocol {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}

final class NetworkClient: NetworkClientProtocol {

    // MARK: - Nested Types

    private enum NetworkError: Error {
        case codeError
    }

    // MARK: - Public Methods

    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: request) {
            data,
            response,
            error in
            if let error {
                handler(.failure(error))
                return
            }

            if let response = response as? HTTPURLResponse,
                response.statusCode < 200 || response.statusCode >= 300
            {
                handler(.failure(NetworkError.codeError))
                return
            }

            guard let data else { return }
            handler(.success(data))
        }

        task.resume()
    }
}
