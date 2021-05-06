//
//  AvatarServiceMock.swift
//  TinkoffChatTests
//
//  Created by Никита Казанцев on 06.05.2021.
//

import Foundation
@testable import TinkoffChat

class MockAvatarService: AvatarServiceProtocol {
    
    let networkManager: NetworkManagerProtocol
    let apiKey: String
    
    var requestsListCalls = 0
    var requestsImageCalls = 0
    
    init(networkManager: NetworkManagerProtocol, apiKey: String) {
        self.networkManager = networkManager
        self.apiKey = apiKey
    }
    
    func loadImageList(handler: @escaping ((Result<[String], Error>) -> Void)) {
        requestsListCalls += 1
        
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
        requestsImageCalls += 1
        
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
