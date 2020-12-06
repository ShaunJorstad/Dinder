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
) -> AnyPublisher<T?, Never> {
    decodeJsonAsync(dataPublisher: getRemoteDataAsync(from: from), decoder: decoder)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
}

func decodeJsonAsync<T: Decodable>(
    dataPublisher: AnyPublisher<Data, Error>,
    decoder: JSONDecoder = JSONDecoder()
) -> AnyPublisher<T?, Never> {
    dataPublisher.decode(type: T.self, decoder: decoder)
        .map{Optional($0)}
        .replaceError(with: nil)
        .eraseToAnyPublisher()
}

func getRemoteDataAsync(from: String) -> AnyPublisher<Data, Error> {
    URLSession.shared
        .dataTaskPublisher(for: URL(string: from)!)
        .tryMap { data, response -> Data in
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    throw DecodeError.invalidServerResponse
            }
            return data
        }
        .eraseToAnyPublisher()
}

func loadJsonFromBundle<T: Decodable>(
    filename: String,
    fileExtension: String,
    decoder: JSONDecoder = JSONDecoder()
) -> AnyPublisher<T?, Never> {
    let fileDataPublisher = Future<URL, Error>{ promise in
        if let fileUrl = Bundle.main.url(forResource: filename, withExtension: fileExtension) {
            return promise(.success(fileUrl))
        }
        
        return promise(.failure(FileError.fileNotFound))
    }
    .tryMap{ try Data(contentsOf: $0) }
    .eraseToAnyPublisher()
    
    return decodeJsonAsync(dataPublisher: fileDataPublisher, decoder: decoder)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
}
