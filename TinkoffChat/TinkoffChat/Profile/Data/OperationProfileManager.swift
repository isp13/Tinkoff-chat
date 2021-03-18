//
//  OperationProfileManager.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 16.03.2021.
//


import UIKit

class OperationProfileDataManager: IProfileDataManager {
    
    lazy var operationQueue: OperationQueue =  {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated // тк юзер нажал на кнопку и ждет выполнения
        return queue
    }()
    
    func save(profile: ProfileViewModel, completion: @escaping ((Bool) -> Void)) {
        var writeOperations = [WriteDataToDiskOperation]()
        
        writeOperations.append(WriteDataToDiskOperation(
                                data: profile.description.data(using: .utf8),
                                fileName: ProfileItemsTags.description.rawValue)
        )
        
        writeOperations.append(WriteDataToDiskOperation(
                                data: profile.name.data(using: .utf8),
                                fileName: ProfileItemsTags.name.rawValue)
        )
        
        writeOperations.append(WriteDataToDiskOperation(
                                data: profile.avatar.pngData(),
                                fileName: ProfileItemsTags.avatar.rawValue)
        )
        
        let writeProfileOperation = WriteProfileOperation(writeOperations: writeOperations, completion: completion)
        
        let allOperations: [Operation] = writeOperations.map { $0 as Operation } + [writeProfileOperation as Operation]
        
        operationQueue.addOperations(allOperations, waitUntilFinished: false)
    }
    
    func read(completion: @escaping ((ProfileViewModel?) -> Void)) {
        let nameOperation = LoadDataFromDiskOperation(fileName: ProfileItemsTags.name.rawValue)
        let descriptionOperation = LoadDataFromDiskOperation(fileName: ProfileItemsTags.description.rawValue)
        let avatarOperation = LoadDataFromDiskOperation(fileName: ProfileItemsTags.avatar.rawValue)
        
        let parseProfile = ReadProfileOperation(
            nameOperation: nameOperation,
            descriptionOperation: descriptionOperation,
            avatarOperation: avatarOperation,
            completion: completion)
        
        operationQueue.addOperations([nameOperation, descriptionOperation, avatarOperation, parseProfile], waitUntilFinished: false)
    }
    
}

class LoadDataFromDiskOperation: Operation {
    
    let fileName: String
    var data: Data?
    
    init(fileName: String) {
        self.fileName = fileName
    }
    
    override func main() {
        guard !isCancelled else { return }
        data = FileUtils.read(fileName: fileName)
    }
}


class WriteDataToDiskOperation: Operation {
    
    let data: Data?
    let fileName: String
    var success: Bool
    
    init(data: Data?, fileName: String) {
        self.data = data
        self.fileName = fileName
        success = data != nil
        
    }
    
    override func main() {
        //sleep(5) // чтоб проверить на случай если мгновенно выходить из вьюшки
        guard !isCancelled else { return }
        
        Logger.log("OPERATION \(fileName)")
        
        
        success = FileUtils.save(data: data, fileName: fileName)
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
