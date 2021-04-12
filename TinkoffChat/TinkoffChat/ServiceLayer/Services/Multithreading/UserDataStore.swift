//
//  UserDataSource.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 16.03.2021.
//
//

import UIKit


protocol IProfileDataManager {
    func save(profile: ProfileViewModel, completion: @escaping((Bool) -> Void))
    
    func read(completion: @escaping((ProfileViewModel?) -> Void))
}

protocol UserDataStoreProtocol {
    var profile: ProfileViewModel? { get set }
    var profileManager: IProfileDataManager { get }
    
    func saveProfile(profile: ProfileViewModel, completion: @escaping (Bool) -> Void)
    func readProfile(completion: @escaping (ProfileViewModel) -> Void)
}

class UserDataStore: UserDataStoreProtocol {
    
    // gcd или operations может быть
    let profileManager: IProfileDataManager
    
    var profile: ProfileViewModel? = ProfileViewModel(name: "ФИО", description: "описание профиля", avatar: UIImage(named: "avatar2") ?? UIImage())
    
    init(profileManager: IProfileDataManager) {
        self.profileManager = profileManager
    }
    
    func saveProfile(profile: ProfileViewModel, completion: @escaping (Bool) -> Void) {
        profileManager.save(profile: profile, completion: completion)
    }
    
    func readProfile(completion: @escaping (ProfileViewModel) -> Void) {
        profileManager.read { (profile) in
            if let profile = profile {
                self.profile = profile
                completion(profile)
            } else {
                let defaultProfile = ProfileViewModel(name: "ФИО", description: "Описание профиля", avatar: UIImage(named: "avatar2") ?? UIImage())
                
                self.profileManager.save(profile: defaultProfile) { _ in
                    self.profile = defaultProfile
                    completion(defaultProfile)
                }
            }
        }
    }
    
}
