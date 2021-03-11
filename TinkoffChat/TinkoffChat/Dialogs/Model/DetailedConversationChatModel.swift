//
//  DetailedConversationChatModel.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 02.03.2021.
//

import Foundation

protocol MessageCellConfiguration {
    var text: String? { get set }
}


struct MessageChatData: MessageCellConfiguration {
    var date: Date?
    var text: String?
    var isMy: Bool?

    init(text: String?, date: Date?, isMy: Bool?) {
        self.text = text
        self.date = date
        self.isMy = isMy
    }
}
