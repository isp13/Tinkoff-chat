//
//  ChannelDB + init.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 31.03.2021.
//

import Foundation
import CoreData
import Firebase

extension Channel_db {

    convenience init(channel: ChannelModel, in context: NSManagedObjectContext) {
        self.init(context: context)
        self.identifier = channel.identifier
        self.name = channel.name
        self.lastMessage = channel.lastMessage
        self.lastActivity = channel.lastActivity
    }
}
