//
//  OperationsTests.swift
//  TinkoffChatTests
//
//  Created by Никита Казанцев on 06.05.2021.
//

import XCTest
@testable import TinkoffChat

class OperationsTests: XCTestCase {

    func testLoadList() {
        let networkManager = NetworkManager()
        let avatarManagerMock = MockAvatarService(networkManager: networkManager, apiKey: "someApi")

        avatarManagerMock.loadImageList { (_) in }

        XCTAssertEqual(avatarManagerMock.requestsListCalls, 1, "must be called once")
        XCTAssertEqual(avatarManagerMock.requestsImageCalls, 0, "must not be called")
        
        XCTAssertNotNil(avatarManagerMock.networkManager.session, "session must not be nil")
    }
}
