//
//  ProfileDiskManager.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 15.03.2021.
//

import UIKit

final class GCDProfileDataManager: IProfileDataManager {

    func save(profile: ProfileViewModel, completion: @escaping((Bool) -> Void)) {
        let group = DispatchGroup()
        
        var success = true
        
        // заполняем очередь
        
        group.enter()
        DispatchQueue.global(qos: .utility).async {
            success = FileUtils.save(
                data: profile.name.data(using: .utf8),
                fileName: ProfileItemsTags.name.rawValue
            )
            group.leave()
        }
        
        group.enter()
        DispatchQueue.global(qos: .utility).async {

            success = FileUtils.save(
                data: profile.description.data(using: .utf8),
                fileName: ProfileItemsTags.description.rawValue
            )
            group.leave()
        }
        
        group.enter()
        DispatchQueue.global(qos: .utility).async {
                
            success = FileUtils.save(
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
            if let nameData = FileUtils.read(fileName: ProfileItemsTags.name.rawValue),
               let descriptionData = FileUtils.read(fileName: ProfileItemsTags.description.rawValue),
               let name = String(data: nameData, encoding: .utf8), // имя профиля
               let description = String(data: descriptionData, encoding: .utf8) { // описание профиля
                let avatarData = FileUtils.read(fileName: ProfileItemsTags.avatar.rawValue) // аватарка
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
