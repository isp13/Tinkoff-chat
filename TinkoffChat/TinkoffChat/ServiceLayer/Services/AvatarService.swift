//
//  AvatarService.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 21.04.2021.
//

import Foundation

protocol AvatarServiceProtocol {
    func loadImageList(handler: @escaping((Result<[String], Error>) -> Void))
    
    func loadImage(urlPath: String, handler: @escaping((Result<Data, Error>) -> Void))
}

class AvatarService: AvatarServiceProtocol {
    
    let networkManager: NetworkManagerProtocol
    let apiKey: String
    
    init(networkManager: NetworkManagerProtocol, apiKey: String) {
        self.networkManager = networkManager
        self.apiKey = apiKey
    }
    
    func loadImageList(handler: @escaping((Result<[String], Error>) -> Void)) {
        networkManager.send(request: ImageListRequest(apiKey: apiKey),
                            parser: AdditionalDecoder<APIImageSearchResponse>()) { (result) in
            switch result {
            case .success(let searchResponse):
                let imageUrls = searchResponse.hits?.compactMap { $0.imageUrl } ?? []
                handler(.success(imageUrls))
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
    func loadImage(urlPath: String, handler: @escaping ((Result<Data, Error>) -> Void)) {
        networkManager.send(request: ImageRequest(urlPath: urlPath),
                            parser: DefaultDecoder()) { (result) in
            switch result {
            case .success(let data):
                handler(.success(data))
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
