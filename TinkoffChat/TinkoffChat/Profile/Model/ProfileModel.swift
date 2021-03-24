//
//  ProfileModel.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 15.03.2021.
//

import UIKit

struct ProfileViewModel {
    let name: String
    let description: String
    let avatar: UIImage
}

enum ProfileItemsTags: String {
    case name = "PROFILE_name"
    case description = "PROFILE_description"
    case avatar = "PROFILE_avatar"
}

