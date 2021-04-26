//
//  ImageRequest.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 21.04.2021.
//

import Foundation

class ImageRequest: RequestProtocol {
    
    var urlRequest: URLRequest? {
        guard let url = URL(string: url) else {
            return nil
        }
        return URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
    }
    
    let url: String
    
    init(urlPath: String) {
        self.url = urlPath
    }
}
