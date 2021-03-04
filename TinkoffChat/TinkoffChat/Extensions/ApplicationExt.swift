//
//  ApplicationExt.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 22.02.2021.
//

import UIKit

#if DEBUG

extension UIApplication.State {

    /// A string representation of `UIApplication.State` to be used as a value for `Event.tags`.
    ///
    var descriptionForEventTag: String {
        switch self {
        case .active:
            return "active"
        case .background:
            return "background"
        case .inactive:
            return "inactive"
        @unknown default:
            return "unknown"
        }
    }
}

#endif
