//
//  ThemeManager.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 09.03.2021.
//

import UIKit

protocol ThemesPickerDelegate: class {
    func themeDidChange(_ theme: Theme)
}

class ThemeManager {
    
    static private(set) var current: Theme = restore()
    
    static func apply() {
        if let storedTheme = UserDefaults.standard.value(forKey: "SelectedTheme") as? Int {
            current = Theme(storedTheme)
        } else {
            current = .Default
        }
    }
    
    static func apply(_ theme: Theme, completion: (() -> Void)? ) {
        DispatchQueue.global(qos: .default).async {
            UserDefaults.standard.setValue(theme.rawValue, forKey: "SelectedTheme")
            UserDefaults.standard.synchronize()
            current = theme
            completion?()
        }
    }
    
    private static func restore() -> Theme {
        if let storedTheme = UserDefaults.standard.value(forKey: "SelectedTheme") as? Int {
            return Theme(storedTheme)
        } else {
            return Theme.Default
        }
    }
    
}
