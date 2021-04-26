//
//  APIImageSearchResponse.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 21.04.2021.
//

import Foundation

struct APIImageSearchResponse: Decodable {
    let total: Int?
    let hits: [ImageAPI]?
}

struct ImageAPI: Decodable {
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case imageUrl = "webformatURL"
    }
}
