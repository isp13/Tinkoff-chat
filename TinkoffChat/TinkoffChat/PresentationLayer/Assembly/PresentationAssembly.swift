//
//  PresentationAssembly.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 11.04.2021.
//

import Foundation
import UIKit

protocol PresenentationAssemblyProtocol {
    func customSplashViewController() -> CustomSplashViewController
    func conversationListViewController() -> ConversationListViewController
    func conversationViewController(channelId: String, channelName: String) -> ConversationViewController
    func profileViewController() -> ProfileViewController
    func settingsViewController() -> ThemesViewController
}

class PresenentationAssembly: PresenentationAssemblyProtocol {
    
    let serviceAssembly: ServiceAssemblyProtocol
    
    init(serviceAssembly: ServiceAssemblyProtocol) {
        self.serviceAssembly = serviceAssembly
    }
    
    func customSplashViewController() -> CustomSplashViewController {
        guard let customSplashViewController = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "customSplashViewController") as? CustomSplashViewController else {
            fatalError("Can't instantiate CustomSplashViewController")
        }
        
        customSplashViewController.presentationAssembly = self
        customSplashViewController.themeDataStore = serviceAssembly.themeDataStore
                                
        return customSplashViewController
    }
    
    func conversationListViewController() -> ConversationListViewController {
        guard let conversationListViewController = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "conversationListViewController") as? ConversationListViewController else {
            fatalError("Can't instantiate ConversationListViewController")
        }
        conversationListViewController.userDataStore = serviceAssembly.userDataService
        conversationListViewController.coreDataService = serviceAssembly.coreDataService
        conversationListViewController.fireStoreService = serviceAssembly.fireStoreService
        conversationListViewController.themeDataStore = serviceAssembly.themeDataStore
        conversationListViewController.theme = serviceAssembly.themeDataStore.theme
        
        conversationListViewController.presentationAssembly = self
        
        return conversationListViewController
    }
        
    func conversationViewController(channelId: String, channelName: String) -> ConversationViewController {
        guard let conversationViewController = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "conversationViewController") as? ConversationViewController else {
            fatalError("Can't instantiate ConversationViewController")
        }
        
        conversationViewController.theme = serviceAssembly.themeDataStore.theme
        conversationViewController.fireStoreService = serviceAssembly.fireStoreService
        conversationViewController.coreDataService = serviceAssembly.coreDataService

        return conversationViewController
    }
    
    func profileViewController() -> ProfileViewController {
        guard let profileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileViewController") as? ProfileViewController else {
            fatalError("Can't instantiate ConversationViewController")
        }
        profileViewController.userDataStore = serviceAssembly.userDataService
        profileViewController.theme = serviceAssembly.themeDataStore.theme
        
        profileViewController.modalPresentationStyle = .overFullScreen
        return profileViewController
    }
    
    func settingsViewController() -> ThemesViewController {
        guard let settingsViewController = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "settings") as? ThemesViewController else {
            fatalError("Can't instantiate ConversationViewController")
        }
        settingsViewController.themeManager = serviceAssembly.themeDataStore
        
        return settingsViewController
    }

    
}
