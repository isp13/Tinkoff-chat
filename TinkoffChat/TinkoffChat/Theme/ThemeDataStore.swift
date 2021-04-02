//
//  ThemeDataStore.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 18.03.2021.
//

import UIKit

class ThemeDataStore {
    
    static var shared: ThemeDataStore = ThemeDataStore()
    
    // gcd or operations
    let gcdManager = GCDThemeManager()
    
    private(set) var theme: Theme = .Default
    
    func saveTheme(theme: Theme, completion: @escaping (Bool) -> Void) {
        self.theme = theme
        gcdManager.save(theme: theme, completion: completion)
    }
    
    func readTheme(completion: @escaping (Theme) -> Void) {
        gcdManager.read { (theme) in
            if let theme = theme {
                self.theme = theme
                completion(theme)
            } else {
                completion(.Default)
            }
        }
    }
}
