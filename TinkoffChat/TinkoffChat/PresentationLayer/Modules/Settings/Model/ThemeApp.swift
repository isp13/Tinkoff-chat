//
//  ThemeApp.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 09.03.2021.
//

import UIKit

class ThemeApp {
    
    var theme: ThemeModel
    
    init(theme: Theme) {
        self.theme = theme.mainColors
    }
}

enum Theme: Int {
    case Default = 0, Day = 1, Night = 2
    
    var mainColors: ThemeModel {
        switch self {
        case .Default:
            return ThemeModel(primaryBackground: .white,
                              navigationBar: NavigationBarThemeModel(background: .white, title: .black, tint: .white, barStyle: .default),
                              chatList: ChatListThemeModel(text: .black, cellBackground: .white),
                              chat: ChatThemeModel(text: .black, myMessageBackground: UIColor.lightGray.withAlphaComponent(0.5),
                                                   yourMessageBackground: UIColor.systemGreen.withAlphaComponent(0.5)),
                              profile: ProfileThemeModel(text: .black),
                              buttons: LargeButtonsThemeModel(primaryButtonBackground: UIColor.lightGray.withAlphaComponent(0.3), text: .systemBlue))
        case .Day:
            return ThemeModel(primaryBackground: .white,
                              navigationBar: NavigationBarThemeModel(background: .white, title: .black, tint: .white, barStyle: .default),
                              chatList: ChatListThemeModel(text: .black, cellBackground: .white),
                              chat: ChatThemeModel(text: .black,
                                                   myMessageBackground: UIColor.lightGray.withAlphaComponent(0.5),
                                                   yourMessageBackground: UIColor.systemBlue.withAlphaComponent(0.5)),
                              profile: ProfileThemeModel(text: .black),
                              buttons: LargeButtonsThemeModel(primaryButtonBackground: UIColor.lightGray.withAlphaComponent(0.3), text: .systemBlue))
        case .Night:
            return ThemeModel(primaryBackground: .black,
                              navigationBar: NavigationBarThemeModel(background: .black, title: .white, tint: .black, barStyle: .black),
                              chatList: ChatListThemeModel(text: .white, cellBackground: .black),
                              chat: ChatThemeModel(text: .white, myMessageBackground: .gray, yourMessageBackground: .lightGray),
                              profile: ProfileThemeModel(text: .white),
                              buttons: LargeButtonsThemeModel(primaryButtonBackground: UIColor.lightGray.withAlphaComponent(0.6), text: .systemBlue))
        }
    }
    
    init(_ value: Int) {
        switch value {
        case 0: self = .Default
        case 1: self = .Day
        case 2: self = .Night
        default: self = .Default
        }
    }
}
