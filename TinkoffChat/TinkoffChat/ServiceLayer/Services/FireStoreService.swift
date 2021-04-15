//
//  FireStoreManager.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 22.03.2021.
//

import Foundation
import Firebase
import CoreData

// MARK: Protocol
protocol FireStoreServiceProtocol {
    var senderId: String { get }
    func updateChannels()
    func updateMessages(identifier: String, channel: ChannelModel)
    func createChannel(name: String, handler: @escaping (Result<String, Error>) -> Void)
    func createMessage(identifier: String, newMessage message: String)
    func deleteChannelMessages(identifier: String)
    func deleteChannel(identifier: String)
}

// MARK: Class
class FireStoreService: FireStoreServiceProtocol {
    lazy var reference = Firestore.firestore().collection("channels")
    
    lazy var senderId = getUUID()
    
    var coredataStack: CoreDataStackProtocol
    
    private var collectionListener: ListenerRegistration?
    
    init(coredataStack: CoreDataStackProtocol) {
        self.coredataStack = coredataStack
        self.coredataStack.addStatisticObserver()
    }
    
    deinit {
        collectionListener?.remove()
    }
    
    /// возврщает диалоги при любом их измерении
    /// - Parameter completion: возвращается массив из объектов класса диалога
    func updateChannels() {
        collectionListener = reference.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else {
                return
            }
            
            if error != nil {
                return
            } else if let snapshot = snapshot {
                var channels: [ChannelModel] = [ChannelModel]()
                
                snapshot.documentChanges.forEach { document in
                    
                    let data = document.document.data()
                    
                    let identifier = document.document.documentID
                    guard let name = data["name"] as? String else { return }
                    let lastMessage = data["lastMessage"] as? String
                    let lastActivity = data["lastActivity"] as? Timestamp
                    
                    let model = ChannelModel(identifier: identifier, name: name, lastMessage: lastMessage, lastActivity: lastActivity?.dateValue())
                    
                    if document.type == .removed { // удаляем канал
                        self.deleteChannelMessages(identifier: model.identifier )
                        self.deleteChannel(identifier: model.identifier )
                    } else { // иначе сохраняем
                        channels.append(model)
                    }
                }
                
                self.coredataStack.performSave { context in
                    channels.forEach {
                        _ = Channel_db(channel: $0, in: context)
                    }
                }
            }
        }
    }
    
    /// возврщает сообщения при любом их измерении
    /// - Parameter completion: возвращается массив из объектов класса сообщения
    func updateMessages(identifier: String, channel: ChannelModel) {
        
        reference.document(identifier).collection("messages").order(by: "created", descending: false).addSnapshotListener { [weak self] (snapshot, error) in
            guard let self = self else {
                return
            }
            Logger.log("updateMessages addSnapshotListener")
            
            if error != nil {
                return
            } else if let snapshot = snapshot {
                var messages = [MessageModel]()
                snapshot.documentChanges.forEach { document in
                    let data = document.document.data()
                    
                    guard let content = data["content"] as? String, content.trimmingCharacters(in: .whitespaces).isEmpty == false else { return }
                    guard let timestamp = data["created"] as? Timestamp else { return }
                    guard let senderId = data["senderId"] as? String else { return }
                    guard let senderName = data["senderName"] as? String else { return }
                    
                    let model = MessageModel(identifier: document.document.documentID, content: content, created: timestamp.dateValue(), senderId: senderId, senderName: senderName)
                    
                    messages.append(model)
                }
                // Core data
                
                self.coredataStack.performSave { context in
                    let channel = Channel_db(channel: channel, in: context)
                    
                    messages.forEach {
                        let message = Message_db(message: $0, in: context)
                        message.channel = channel
                        channel.addToMessages(message)
                    }
                }
                
            }
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
    
    /// отсылка сообщения на сервер
    func createMessage(identifier: String, newMessage message: String) {
        reference.document(identifier).collection("messages").addDocument(
            data: [
                "content": message,
                "created": Timestamp(date: Date()),
                "senderId": senderId,
                "senderName": "Nikita Kazantsev"])
        
    }
    
    // удаление канала из fireStore
    private func deleteChannelFireStore(identifier: String) {
        reference.document(identifier).delete()
    }
    
    // удаление сообщений из fireStore
    private func deleteMessageFireStore(identifier: String) {
        reference.document(identifier).collection("messages").document(identifier).delete()
    }
    
    // удаление сообщений из бд
    public func deleteChannelMessages(identifier: String) {
        self.coredataStack.performSave { (context) in
            if let result = try? context.fetch(Message_db.fetchRequest(identifier: identifier)) {
                result.forEach {
                    context.delete($0)
                    self.deleteMessageFireStore(identifier: $0.identifier ?? "")
                }
            }
            
        }
    }
    
    // удаление канала из бд
    public func deleteChannel(identifier: String) {
        self.coredataStack.performSave { (context) in
            if let result = try? context.fetch(Channel_db.fetchRequest(identifier: identifier)) {
                result.forEach {
                    context.delete($0)
                    self.deleteChannelFireStore(identifier: $0.identifier ?? "")
                }
                
            }
            
        }
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
