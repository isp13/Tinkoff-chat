//
//  ProfileModel.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 15.03.2021.
//

import UIKit

struct ProfileViewModel: Equatable {
    let name: String
    let description: String
    let avatar: UIImage
    
    public static func == (first: ProfileViewModel, second: ProfileViewModel) -> Bool {
        return first.name == second.name &&
            first.description == second.description &&
            first.avatar === second.avatar
    }
}

enum ProfileItemsTags: String {
    case name = "PROFILE_name"
    case description = "PROFILE_description"
    case avatar = "PROFILE_avatar"
}
