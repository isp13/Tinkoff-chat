//
//  FireStoreManager.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 22.03.2021.
//

import Foundation
import Firebase

class FireStoreManager {
    static var shared = FireStoreManager()
    
    lazy var reference = Firestore.firestore().collection("channels")
    
    lazy var senderId = getUUID()
    
    private var collectionListener: ListenerRegistration?
    
    deinit {
        collectionListener?.remove()
    }
    
    /// возврщает диалоги при любом их измерении
    /// - Parameter completion: возвращается массив из объектов класса диалога
    func updateChannels(completion: @escaping ([ChannelModel]) -> Void) {
        collectionListener = reference.addSnapshotListener { snapshot, error in
            if error != nil {
                return
            }
            
            var channels: [ChannelModel] = [ChannelModel]()
            
            _ = snapshot?.documents.map({ document in
                let data = document.data()
                let identifier = document.documentID // , identifier.isEmpty == false else { return }
                
                guard let name = data["name"] as? String else { return }
                
                let lastMessage = data["lastMessage"] as? String
                
                let lastActivity = data["lastActivity"] as? Timestamp
                
                let model = ChannelModel(identifier: identifier, name: name, lastMessage: lastMessage, lastActivity: lastActivity?.dateValue())
                
                channels.append(model)
            })
            
            channels.sort { $0.lastActivity ?? Date() > $1.lastActivity ?? Date() }
            completion(channels)
        }
    }
    
    /// единовременная подгрузка диалогов
    func fetchChannels(completion: @escaping ([ChannelModel]) -> Void) {
        
        var channels: [ChannelModel] = [ChannelModel]()
        
        reference.getDocuments { snapshot, _ in
            _ = snapshot?.documents.map({ document in
                let data = document.data()
                let identifier = document.documentID// , identifier.isEmpty == false else { return }
                guard let name = data["name"] as? String, name.trimmingCharacters(in: .whitespaces).isEmpty == false else { return }
                
                let lastMessage = data["lastMessage"] as? String
                
                let lastActivity = data["lastActivity"] as? Timestamp
                
                let model = ChannelModel(identifier: identifier, name: name, lastMessage: lastMessage, lastActivity: lastActivity?.dateValue())
                
                channels.append(model)
            })
            
            completion(channels)
        }
    }
    
    /// единовременная подгрузка сообщений в диалоге
    func fetchChannelMessages( identifier: String, completion: @escaping ([MessageModel]) -> Void) {
        var messages = [MessageModel]()
        reference.document(identifier).collection("messages").getDocuments { snapshot, _ in
            _ = snapshot?.documents.map({ document in
                let data = document.data()
                
                guard let content = data["content"] as? String, content.trimmingCharacters(in: .whitespaces).isEmpty == false else { return }
                
                guard let timestamp = data["created"] as? Timestamp else { return }
                guard let senderId = data["senderId"] as? String else { return }
                guard let senderName = data["senderName"] as? String else { return }
                
                let model = MessageModel(content: content, created: timestamp.dateValue(), senderId: senderId, senderName: senderName)
                
                messages.append(model)
            })
            
            completion(messages)
        }
        
    }
    
    /// создание канала на сервере
    /// - Parameters:
    ///   - name: название канала
    func createChannel(name: String, handler: @escaping (Result<String, Error>) -> Void) {
        var ref: DocumentReference?
        ref = reference.addDocument(data: ["name": name]) { (error) in
            if let error = error {
                handler(.failure(error))
            } else if let channelId = ref?.documentID {
                handler(.success(channelId))
            } else {
                handler(.failure(NSError()))
            }
        }
    }
    
    /// возврщает сообщения при любом их измерении
    /// - Parameter completion: возвращается массив из объектов класса сообщения
    func updateMessages(identifier: String, completion: @escaping ([MessageModel]) -> Void) {
        
        reference.document(identifier).collection("messages").order(by: "created", descending: false).addSnapshotListener { (snapshot, error) in
            
            var messages = [MessageModel]()
            
            if error != nil {
                return
            }
            
            _ = snapshot?.documents.map({ document in
                let data = document.data()
                
                guard let content = data["content"] as? String, content.trimmingCharacters(in: .whitespaces).isEmpty == false else { return }
                
                guard let timestamp = data["created"] as? Timestamp else { return }
                guard let senderId = data["senderId"] as? String else { return }
                guard let senderName = data["senderName"] as? String else { return }
                
                let model = MessageModel(content: content, created: timestamp.dateValue(), senderId: senderId, senderName: senderName)
                
                messages.append(model)
            })
            
            completion(messages)
            
        }
    }
    
    /// отсылка сообщения на сервер
    func createMessage(identifier: String, newMessage message: String) {
        
        reference.document(identifier).collection("messages").addDocument(
            data: [
                "content": message,
                "created": Timestamp(date: Date()),
                "senderId": senderId,
                "senderName": "Nikita Kazantsev"]) 
    }
    
    private func getUUID() -> String {
        if let uuid = UserDefaults.standard.value(forKey: "MY_UUID") as? String, !uuid.isEmpty {
            return uuid
        } else {
            let uuid = UUID().uuidString
            UserDefaults.standard.set(uuid, forKey: "MY_UUID")
            return uuid
        }
    }
}
