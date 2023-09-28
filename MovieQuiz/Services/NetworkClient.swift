//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Арина Колганова on 09.09.2023.
//

import Foundation

protocol NetworkRouting {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> String?)
}

struct NetworkClient: NetworkRouting {
    
    private enum NetworkError: Error {
        case codeError
        case custom(message: String)
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> String?) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                let answer = handler(.failure(error))
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode < 200 || response.statusCode >= 300 {
                    let answer = handler(.failure(NetworkError.codeError))
                    return
                } else {
                    guard let data = data else { return }
                    let answer = handler(.success(data))
                    if let answer = answer, !answer.isEmpty {
                        let answer = handler(.failure(NetworkError.custom(message: answer)))
                    }
                }
            }
        }
        
        task.resume()
    }
}
