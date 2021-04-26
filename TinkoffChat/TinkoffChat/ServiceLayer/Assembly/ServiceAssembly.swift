//
//  ServiceAssembly.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 11.04.2021.
//

import Foundation

protocol ServiceAssemblyProtocol {
    var fireStoreService: FireStoreServiceProtocol { get }
    var coreDataService: CoreDataServiceProtocol { get }
    var userDataService: UserDataStoreProtocol { get }
    var operationService: IProfileDataManager { get }
    
    var themeDataStore: ThemeDataStore { get }
    
    var avatarService: AvatarServiceProtocol { get }
    
}

class ServiceAssembly: ServiceAssemblyProtocol {
    
    private let coreAssembly: CoreAssemblyProtocol
    
    // Services
    lazy var fireStoreService: FireStoreServiceProtocol = FireStoreService(coredataStack: coreAssembly.coreDataStack)
    
    lazy var coreDataService: CoreDataServiceProtocol = CoreDataService(coreDataStack: coreAssembly.coreDataStack)
    
    lazy var operationService: IProfileDataManager = OperationProfileDataManager(fileManager: coreAssembly.fileManager)
    
    lazy var userDataService: UserDataStoreProtocol = UserDataStore(profileManager: operationService)
    
    lazy var themeDataStore: ThemeDataStore = ThemeDataStore(gcdManager: coreAssembly.gcdThemeManager)
    
    lazy var avatarService: AvatarServiceProtocol = AvatarService(networkManager: coreAssembly.networkManager, apiKey: "16389761-71807c2be9329dee63565e348")
    
    init(coreAssembly: CoreAssemblyProtocol) {
        self.coreAssembly = coreAssembly
    }
}
