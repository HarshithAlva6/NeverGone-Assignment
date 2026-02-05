//
//  NeverGoneDemoTests.swift
//  NeverGoneDemoTests
//
//  Created by Harshith Harijeevan on 2/4/26.
//

import XCTest
@testable import NeverGoneDemo

final class NeverGoneDemoTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testChatMessageInitialization() {
        let id = UUID()
        let sessionId = UUID()
        let authorId = UUID()
        let content = "Hello, world!"
        let now = Date()
        
        let message = ChatMessage(
            id: id,
            sessionId: sessionId,
            authorId: authorId,
            content: content,
            role: .user,
            createdAt: now
        )
        
        XCTAssertEqual(message.id, id)
        XCTAssertEqual(message.content, content)
        XCTAssertEqual(message.role, .user)
    }
    
    func testChatMessageJSONDecoding() throws {
        let json = """
        {
            "id": "\(UUID().uuidString)",
            "session_id": "\(UUID().uuidString)",
            "author_id": "\(UUID().uuidString)",
            "content": "Test content",
            "role": "assistant",
            "created_at": "2024-02-04T12:00:00Z"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let message = try decoder.decode(ChatMessage.self, from: json)
        
        XCTAssertEqual(message.content, "Test content")
        XCTAssertEqual(message.role, .assistant)
    }

}
