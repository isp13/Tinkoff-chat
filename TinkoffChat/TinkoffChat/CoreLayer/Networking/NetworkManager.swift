//
//  NetworkManager.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 21.04.2021.
//

import Foundation

protocol RequestProtocol {
    var urlRequest: URLRequest? { get }
}
protocol NetworkManagerProtocol {
    var session: URLSession { get }
    
    func send<Model, Parser>(request: RequestProtocol, parser: Parser,
                             handler: @escaping(Result<Model, Error>) -> Void) where Parser: ResponseParserProtocol, Parser.Model == Model
}

class NetworkManager: NetworkManagerProtocol {
    
    enum Errors: Error {
        case requestError(_ string: String)
    }
    
    let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func send<Model, Parser>(request: RequestProtocol, parser: Parser,
                             handler: @escaping(Result<Model, Error>) -> Void) where Model == Parser.Model, Parser: ResponseParserProtocol {
        
        guard let urlRequest = request.urlRequest else {
            handler(.failure(Errors.requestError("urlRequest nil")))
            return
        }
        let task = session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                handler(.failure(error))
                return
            } else if let response = (response as? HTTPURLResponse),
                      !(200...299).contains(response.statusCode) {
                handler(.failure(Errors.requestError("status code error")))
            } else if let data = data {
                if let model = parser.parse(data: data) {
                    handler(.success(model))
                } else {
                    handler(.failure(Errors.requestError("unable to parse")))
                }
            }
        }
        
        task.resume()
    }
    
}
