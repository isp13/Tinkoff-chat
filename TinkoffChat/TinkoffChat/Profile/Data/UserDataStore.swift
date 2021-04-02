//
//  UserDataSource.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 16.03.2021.
//
//

import UIKit

class UserDataStore {
    
    static var shared: UserDataStore = UserDataStore()
    
    // gcd или operations может быть
    let profileManager: IProfileDataManager
    
    private(set) var profile: ProfileViewModel? = ProfileViewModel(name: "ФИО", description: "описание профиля", avatar: UIImage(named: "avatar2") ?? UIImage())
    
    init(profileManager: IProfileDataManager = GCDProfileDataManager()) {
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
