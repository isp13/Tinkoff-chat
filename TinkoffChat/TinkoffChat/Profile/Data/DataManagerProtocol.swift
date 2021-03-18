//
//  DataManagerProtocol.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 15.03.2021.
//


import Foundation

protocol IProfileDataManager {
    func save(profile: ProfileViewModel, completion: @escaping((Bool) -> Void))
    
    func read(completion: @escaping((ProfileViewModel?) -> Void))
}
