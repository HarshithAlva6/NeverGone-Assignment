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
    
    func testStreamingLogicWithMockedStream() async throws {
        let expectedChunks = ["Hello", " ", "world", "!"]
        var receivedChunks: [String] = []
        
        let mockStream = AsyncThrowingStream<String, Error> { continuation in
            Task {
                for chunk in expectedChunks {
                    continuation.yield(chunk)
                    try? await Task.sleep(nanoseconds: 10_000_000)
                }
                continuation.finish()
            }
        }
        
        for try await chunk in mockStream {
            receivedChunks.append(chunk)
        }
        
        XCTAssertEqual(receivedChunks, expectedChunks)
        XCTAssertEqual(receivedChunks.joined(), "Hello world!")
    }
    
    func testStreamingCancellation() async throws {
        var receivedCount = 0
        let expectation = XCTestExpectation(description: "Stream should be cancelled")
        
        let mockStream = AsyncThrowingStream<String, Error> { continuation in
            Task {
                for i in 1...100 {
                    if Task.isCancelled {
                        continuation.finish()
                        return
                    }
                    continuation.yield("Chunk \(i)")
                    try? await Task.sleep(nanoseconds: 10_000_000)
                }
                continuation.finish()
            }
        }
        
        let task = Task {
            for try await chunk in mockStream {
                receivedCount += 1
                if receivedCount == 5 {
                    expectation.fulfill()
                    break
                }
            }
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
        task.cancel()
        
        XCTAssertEqual(receivedCount, 5)
        XCTAssertTrue(receivedCount < 100, "Stream should have been cancelled before completing all chunks")
    }
}
