//
//  ProfileDiskManager.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 15.03.2021.
//

import UIKit

final class GCDProfileDataManager: IProfileDataManager {
    var fileManager: FileUtilsManagerProtocol
    
    init(fileManager: FileUtilsManagerProtocol) {
        self.fileManager = fileManager
    }
    
    func save(profile: ProfileViewModel, completion: @escaping((Bool) -> Void)) {
        let group = DispatchGroup()
        
        var success = true
        
        // заполняем очередь
        
        group.enter()
        DispatchQueue.global(qos: .utility).async {
            success = self.fileManager.save(
                data: profile.name.data(using: .utf8),
                fileName: ProfileItemsTags.name.rawValue
            )
            group.leave()
        }
        
        group.enter()
        DispatchQueue.global(qos: .utility).async {

            success = self.fileManager.save(
                data: profile.description.data(using: .utf8),
                fileName: ProfileItemsTags.description.rawValue
            )
            group.leave()
        }
        
        group.enter()
        DispatchQueue.global(qos: .utility).async {
                
            success = self.fileManager.save(
                data: profile.avatar.pngData(),
                fileName: ProfileItemsTags.avatar.rawValue
            )
            group.leave()
        }

        group.notify(queue: .global(qos: .default)) {
            completion(success) // в случае успеха записи всех трех полей вернется true
        }
    }
    
    func read(completion: @escaping((ProfileViewModel?) -> Void)) {
        DispatchQueue.global(qos: .utility).async {
            if let nameData = self.fileManager.read(fileName: ProfileItemsTags.name.rawValue),
               let descriptionData = self.fileManager.read(fileName: ProfileItemsTags.description.rawValue),
               let name = String(data: nameData, encoding: .utf8), // имя профиля
               let description = String(data: descriptionData, encoding: .utf8) { // описание профиля
                let avatarData = self.fileManager.read(fileName: ProfileItemsTags.avatar.rawValue) // аватарка
                var avatar: UIImage?
                
                if let data = avatarData {
                    avatar = UIImage(data: data)
                }
                
                let profile = ProfileViewModel(name: name, description: description, avatar: avatar ?? UIImage())
                
                completion(profile)
              
            } else {
                completion(nil)
            }
        }
    }
    
}
