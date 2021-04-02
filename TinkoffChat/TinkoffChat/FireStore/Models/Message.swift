//
//  Message.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 22.03.2021.
//

import Foundation

struct MessageModel {
    let identifier: String
    let content: String
    let created: Date
    let senderId: String
    let senderName: String
}
