//
//  CoreAssembly.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 11.04.2021.
//

import Foundation

protocol CoreAssemblyProtocol {
    var fileManager: FileUtilsManagerProtocol { get }
    var coreDataStack: CoreDataStackProtocol { get set }
    var gcdThemeManager: GCDThemeManager { get }
    
}

class CoreAssembly: CoreAssemblyProtocol {
    lazy var fileManager: FileUtilsManagerProtocol = FileUtils()
    lazy var coreDataStack: CoreDataStackProtocol = CoreDataStack()
    lazy var gcdThemeManager: GCDThemeManager = GCDThemeManager(fileManager: fileManager)
}
