//
//  Logger.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 22.02.2021.
//

import UIKit

class Logger {
    static func log(_ text: String) {
        #if DEBUG
        print(text)
        #endif
    }
}
