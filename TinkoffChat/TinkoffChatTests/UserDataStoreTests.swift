//
//  UserDataStoreTests.swift
//  TinkoffChatTests
//
//  Created by Никита Казанцев on 06.05.2021.
//

import XCTest
@testable import TinkoffChat

class UserDataStoreTests: XCTestCase {
    
    func testDataStoreReadSaveEqual() throws {
        let mockProfile = ProfileViewModel(name: "Nick", description: "Kazantsev", avatar: UIImage())
        let currentProfile = ProfileViewModel(name: "Nick", description: "Kazantsev", avatar: UIImage())
        
        let mockProfileDataManager = MockProfileDataManager(mockProfile: mockProfile)
        let userDataStore = UserDataStore(profileManager: mockProfileDataManager)
        
        userDataStore.saveProfile(profile: currentProfile) { _ in }
        
        userDataStore.readProfile { (profile) in
            XCTAssert(mockProfile == profile, "profile from disk must be equal to saved one")
        }
        
        XCTAssert(mockProfileDataManager.writeToDiskCount == 1, "write must be called once")
        XCTAssert(mockProfileDataManager.readProfileFromDiskCount == 1, "read must be called once")
    }
    
    func testDataStoreReadSaveNotEqual() throws {
        let mockProfile = ProfileViewModel(name: "Nick", description: "Kazantsev", avatar: UIImage())
        let diffProfile1 = ProfileViewModel(name: "NotNick", description: "NotKazantsev", avatar: UIImage())
        let diffProfile2 = ProfileViewModel(name: "Sergey", description: "Abrslsd", avatar: UIImage())
        
        let mockProfileDataManager = MockProfileDataManager(mockProfile: mockProfile)
        let userDataStore = UserDataStore(profileManager: mockProfileDataManager)
        
        userDataStore.saveProfile(profile: diffProfile1) { _ in }
        
        userDataStore.readProfile { (profile) in
            XCTAssert(profile != diffProfile2, "profile from disk must be not equal to saved one")
        }
        
        XCTAssert(mockProfileDataManager.writeToDiskCount == 1, "write must be called once")
        XCTAssert(mockProfileDataManager.readProfileFromDiskCount == 1, "read must be called once")
    }
    
}
