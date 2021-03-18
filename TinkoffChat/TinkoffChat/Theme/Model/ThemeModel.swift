//
//  ThemeModel.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 11.03.2021.
//

import UIKit


struct ThemeModel {
    let primaryBackground: UIColor
    let navigationBar: NavigationBarThemeModel
    let chatList: ChatListThemeModel
    let chat: ChatThemeModel
    let profile: ProfileThemeModel
    let buttons: LargeButtonsThemeModel
}

struct NavigationBarThemeModel {
    let background: UIColor
    let title: UIColor
    let tint: UIColor
    let barStyle: UIBarStyle
}

struct ChatListThemeModel {
    let text: UIColor
    let cellBackground: UIColor
}

struct ChatThemeModel {
    let text: UIColor
    let myMessageBackground: UIColor
    let yourMessageBackground: UIColor
}

struct ProfileThemeModel {
    let text: UIColor
}

struct LargeButtonsThemeModel {
    let primaryButtonBackground: UIColor
    let text: UIColor
}

enum ThemeItemsTags: String {
    case themeStyle = "theme"
}

