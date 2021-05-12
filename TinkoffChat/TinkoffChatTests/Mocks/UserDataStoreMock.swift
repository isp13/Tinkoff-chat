//
//  UserDataStoreMock.swift
//  TinkoffChatTests
//
//  Created by Никита Казанцев on 06.05.2021.
//

import Foundation
@testable import TinkoffChat

class MockProfileDataManager: IProfileDataManager {
    
    var receivedProfile: ProfileViewModel?
    var writeToDiskCount = 0
    var readProfileFromDiskCount = 0
    
    private let mockProfile: ProfileViewModel
    
    init(mockProfile: ProfileViewModel) {
        self.mockProfile = mockProfile
    }
    
    func save(profile: ProfileViewModel, completion: @escaping ((Bool) -> Void)) {
        writeToDiskCount += 1
        receivedProfile = profile
        completion(true)
    }
    
    func read(completion: @escaping ((ProfileViewModel?) -> Void)) {
        readProfileFromDiskCount += 1
        completion(mockProfile)
    }

}
