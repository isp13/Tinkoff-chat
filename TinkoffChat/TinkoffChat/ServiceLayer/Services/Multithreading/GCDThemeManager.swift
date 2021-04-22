//
//  GCDThemeManager.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 18.03.2021.
//

import UIKit

final class GCDThemeManager {
    var fileManager: FileUtilsManagerProtocol
    
    init (fileManager: FileUtilsManagerProtocol) {
        self.fileManager = fileManager
    }
    
    func save(theme: Theme, completion: @escaping((Bool) -> Void)) {
        let group = DispatchGroup()
        
        var success = true
        
        // ЗДЕСЬ ЗАПИСЬ
        group.enter()
        DispatchQueue.global(qos: .utility).async {
            success = self.fileManager.save(
                data: String(theme.rawValue).data(using: .utf8),
                fileName: ThemeItemsTags.themeStyle.rawValue
            )
            group.leave()
        }
        
        group.notify(queue: .global(qos: .default)) {
            completion(success)
        }
    }
    
    func read(completion: @escaping((Theme?) -> Void)) {
        DispatchQueue.global(qos: .utility).async {
            if let theme = self.fileManager.read(fileName: ThemeItemsTags.themeStyle.rawValue),
               let themeRaw = String(data: theme, encoding: .utf8),
               let themeIndex = Int(themeRaw) {
                completion(Theme(themeIndex))
            } else {
                completion(nil)
            }
        }
    }
}
