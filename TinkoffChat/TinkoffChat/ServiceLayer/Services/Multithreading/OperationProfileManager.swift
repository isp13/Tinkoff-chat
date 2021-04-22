//
//  OperationProfileManager.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 16.03.2021.
//

import UIKit

class OperationProfileDataManager: IProfileDataManager {
    
    var fileManager: FileUtilsManagerProtocol
    
    init(fileManager: FileUtilsManagerProtocol) {
        self.fileManager = fileManager
    }
    
    lazy var operationQueue: OperationQueue =  {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated // тк юзер нажал на кнопку и ждет выполнения
        return queue
    }()
    
    func save(profile: ProfileViewModel, completion: @escaping ((Bool) -> Void)) {
        var writeOperations = [WriteDataToDiskOperation]()
        
        writeOperations.append(WriteDataToDiskOperation(
                                data: profile.description.data(using: .utf8),
                                fileName: ProfileItemsTags.description.rawValue, fileManager: fileManager)
        )
        
        writeOperations.append(WriteDataToDiskOperation(
                                data: profile.name.data(using: .utf8),
                                fileName: ProfileItemsTags.name.rawValue, fileManager: fileManager)
        )
        
        writeOperations.append(WriteDataToDiskOperation(
                                data: profile.avatar.pngData(),
                                fileName: ProfileItemsTags.avatar.rawValue, fileManager: fileManager)
        )
        
        let writeProfileOperation = WriteProfileOperation(writeOperations: writeOperations, completion: completion)
        
        let allOperations: [Operation] = writeOperations.map { $0 as Operation } + [writeProfileOperation as Operation]
        
        operationQueue.addOperations(allOperations, waitUntilFinished: false)
    }
    
    func read(completion: @escaping ((ProfileViewModel?) -> Void)) {
        let nameOperation = LoadDataFromDiskOperation(fileName: ProfileItemsTags.name.rawValue, fileManager: self.fileManager)
        let descriptionOperation = LoadDataFromDiskOperation(fileName: ProfileItemsTags.description.rawValue, fileManager: self.fileManager)
        let avatarOperation = LoadDataFromDiskOperation(fileName: ProfileItemsTags.avatar.rawValue, fileManager: self.fileManager)
        
        let parseProfile = ReadProfileOperation(
            nameOperation: nameOperation,
            descriptionOperation: descriptionOperation,
            avatarOperation: avatarOperation,
            completion: completion)
        
        operationQueue.addOperations([nameOperation, descriptionOperation, avatarOperation, parseProfile], waitUntilFinished: false)
    }
    
}

class LoadDataFromDiskOperation: Operation {
    var fileManager: FileUtilsManagerProtocol
    let fileName: String
    var data: Data?
    
    init(fileName: String, fileManager: FileUtilsManagerProtocol) {
        self.fileName = fileName
        self.fileManager = fileManager
    }
    
    override func main() {
        guard !isCancelled else { return }
        data = fileManager.read(fileName: fileName)
    }
}

class WriteDataToDiskOperation: Operation {
    var fileManager: FileUtilsManagerProtocol
    let data: Data?
    let fileName: String
    var success: Bool
    
    init(data: Data?, fileName: String, fileManager: FileUtilsManagerProtocol) {
        self.data = data
        self.fileName = fileName
        success = data != nil
        
        self.fileManager = fileManager
    }
    
    override func main() {
        // sleep(5) // чтоб проверить на случай если мгновенно выходить из вьюшки
        guard !isCancelled else { return }
        
        Logger.log("OPERATION \(fileName)")
        
        success = fileManager.save(data: data, fileName: fileName)
    }
}

class WriteProfileOperation: Operation {
    
    let operations: [WriteDataToDiskOperation]
    
    let completion: ((Bool) -> Void)
    
    init(writeOperations: [WriteDataToDiskOperation], completion: @escaping ((Bool) -> Void) ) {
        self.operations = writeOperations
        self.completion = completion
        super.init()
        
        // эта операция должна дождаться как выполняться все до нее (запись картинки, имени, описания профиля)
        writeOperations.forEach {
            self.addDependency($0)
        }
    }
    
    override func main() {
        
        Logger.log("OPERATION WriteProfileOperation")
        guard !isCancelled else {
            completion(false)
            return
        }
        let hasErrors = operations.contains(where: { !$0.success })
        
        completion(!hasErrors)
    }
}

class ReadProfileOperation: Operation {
    let nameOperation: LoadDataFromDiskOperation
    let descriptionOperation: LoadDataFromDiskOperation
    let avatarOperation: LoadDataFromDiskOperation
    
    let completion: ((ProfileViewModel?) -> Void)
    var profile: ProfileViewModel?
    
    init(nameOperation: LoadDataFromDiskOperation,
         descriptionOperation: LoadDataFromDiskOperation,
         avatarOperation: LoadDataFromDiskOperation,
         completion: @escaping ((ProfileViewModel?) -> Void) ) {
        self.nameOperation = nameOperation
        self.descriptionOperation = descriptionOperation
        self.avatarOperation = avatarOperation
        self.completion = completion
        
        super.init()
        
        addDependency(nameOperation)
        addDependency(descriptionOperation)
        addDependency(avatarOperation)
    }
    
    override func main() {
        guard !isCancelled else { return }
        
        guard let nameData = nameOperation.data,
              let descriptionData = descriptionOperation.data,
              let avatarData = avatarOperation.data,
              let name = String(data: nameData, encoding: .utf8),
              let description = String(data: descriptionData, encoding: .utf8)
        else {
            Logger.log("error in operation")
            completion(nil)
            return
        }
        profile = ProfileViewModel(name: name, description: description, avatar: UIImage(data: avatarData) ?? UIImage())
        completion(profile)
    }
    
}
