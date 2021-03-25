//
//  Channel.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 22.03.2021.
//

import Foundation

struct ChannelModel {
    let identifier: String
    let name: String
    let lastMessage: String?
    let lastActivity: Date?
}
