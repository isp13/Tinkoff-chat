//
//  ImageListRequest.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 21.04.2021.
//

import Foundation

class ImageListRequest: RequestProtocol {
       
    var urlRequest: URLRequest? {
        var urlComponents = URLComponents(string: host)
        urlComponents?.queryItems = []
        urlComponents?.queryItems?.append(.init(name: "key", value: apiKey))
        urlComponents?.queryItems?.append(.init(name: "image_type", value: imageType))
        urlComponents?.queryItems?.append(.init(name: "per_page", value: "100"))
        guard let url = urlComponents?.url else {
            return nil
        }
        return URLRequest(url: url)
    }
    
    private let apiKey: String
    
    private let host = "https://pixabay.com/api/"
    
    private let imageType = "photo"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
 
}
