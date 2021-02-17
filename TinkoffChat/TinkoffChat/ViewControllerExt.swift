//
//  ViewControllerExt.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 13.02.2021.
//

import UIKit

extension UIViewController {
    
    func logCicle(_ function: String = #function) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            appDelegate.loggingEnabled
        else {
            return
        }
        appDelegate.logCicle(function)
    }
}
