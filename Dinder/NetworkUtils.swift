//
//  NetworkUtils.swift
//  Dinder
//
//  Created by Luke on 12/5/20.
//

import Foundation
import Combine

enum DecodeError: Error {
    case invalidServerResponse
}

enum FileError: Error {
    case fileNotFound
}

func downloadJsonAsync<T: Decodable>(
    from: String,
    decoder: JSONDecoder = JSONDecoder()
) -> AnyPublisher<T, Error> {
    URLSession.shared
        .dataTaskPublisher(for: URL(string: from)!)
        .tryMap { data, response -> Data in
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    throw DecodeError.invalidServerResponse
            }
            return data
        }
        .decode(type: T.self, decoder: decoder)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
}

func loadJsonFromBundle<T: Decodable>(
    filename: String,
    fileExtension: String,
    decoder: JSONDecoder = JSONDecoder()
) -> AnyPublisher<T?, Never> {
    Future<URL, Error>{ promise in
        if let fileUrl = Bundle.main.url(forResource: filename, withExtension: fileExtension) {
            return promise(.success(fileUrl))
        }
        
        return promise(.failure(FileError.fileNotFound))
    }
    .tryMap{ try Data(contentsOf: $0) }
    .decode(type: T.self, decoder: decoder)
    .map{Optional($0)}
    .replaceError(with: nil)
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
}
