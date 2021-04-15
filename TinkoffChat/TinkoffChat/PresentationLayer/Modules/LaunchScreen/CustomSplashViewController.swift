//
//  CustomSplashViewController.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 18.03.2021.
//

import UIKit

class CustomSplashViewController: UIViewController {
    var presentationAssembly: PresenentationAssemblyProtocol?
    var themeDataStore: ThemeDataStore?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyThemeRedirect()
    }
    
    private func applyThemeRedirect() {
        guard let conversationListViewController = presentationAssembly?.conversationListViewController() else { return }
        
        themeDataStore?.readTheme { theme in
            DispatchQueue.main.async {
                self.view.backgroundColor = theme.mainColors.primaryBackground

                self.navigationController?.pushViewController(conversationListViewController, animated: true)
            }
        }
    }
}
