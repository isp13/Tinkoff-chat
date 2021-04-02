//
//  Message_db + init.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 31.03.2021.
//

import Foundation
import CoreData
import Firebase

extension Message_db {

    convenience init(message: MessageModel, in context: NSManagedObjectContext) {
        self.init(context: context)
        self.identifier = message.identifier
        self.content = message.content
        self.senderId = message.senderId
        self.senderName = message.senderName
        self.created = message.created
    }
}
