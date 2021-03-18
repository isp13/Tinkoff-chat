//
//  CustomSplashViewController.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 18.03.2021.
//

import UIKit

class CustomSplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ThemeDataStore.shared.readTheme { theme in
            DispatchQueue.main.async {
            self.view.backgroundColor = theme.mainColors.primaryBackground
 
            self.performSegue(withIdentifier: "showMainAppViews", sender: self)
            }
        }
    }
}
