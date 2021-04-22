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
    
    @nonobjc public class func fetchRequest(identifier: String) -> NSFetchRequest<Message_db> {
            let request = NSFetchRequest<Message_db>(entityName: "Message_db")
            request.predicate = NSPredicate(format: "identifier == %@", identifier)
            return request
        }

    convenience init(message: MessageModel, in context: NSManagedObjectContext) {
        self.init(context: context)
        self.identifier = message.identifier
        self.content = message.content
        self.senderId = message.senderId
        self.senderName = message.senderName
        self.created = message.created
    }
}
