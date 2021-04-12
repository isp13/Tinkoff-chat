//
//  ScrollVIewExt.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 24.03.2021.
//

import UIKit

extension UIScrollView {
    func scrollsToBottom(animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height)
        setContentOffset(bottomOffset, animated: animated)
    }
}
