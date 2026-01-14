//
//  ChatAPIModels.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import Foundation

struct ChatsResponse: Codable {
    let count: Int?
    let chats: [ChatAPIModel]?
}

struct ChatAPIModel: Codable {
    let id: Int
    let type: String?
    let name: String?
    let avatarUrl: String?
    let otherUser: OtherUserModel?
    let lastMessage: LastMessageModel?
    let unreadCount: Int?
    let isInInbox: Bool?
    let inboxReason: String?
    
    enum CodingKeys: String, CodingKey {
        case id, type, name
        case avatarUrl = "avatar_url"
        case otherUser = "other_user"
        case lastMessage = "last_message"
        case unreadCount = "unread_count"
        case isInInbox = "is_in_inbox"
        case inboxReason = "inbox_reason"
    }
}

struct OtherUserModel: Codable {
    let id: Int
    let name: String?
    let avatarUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case avatarUrl = "avatar_url"
    }
}

struct LastMessageModel: Codable {
    let id: Int?
    let senderId: Int?
    let content: String?
    let videoId: Int?
    let nomenclatureId: String?
    let createdAt: String?
    let isRead: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case senderId = "sender_id"
        case content
        case videoId = "video_id"
        case nomenclatureId = "nomenclature_id"
        case createdAt = "created_at"
        case isRead = "is_read"
    }
}

struct MessagesResponse: Codable {
    let messages: [MessageAPIModel]?
    let items: [MessageAPIModel]?
    
    var allMessages: [MessageAPIModel] {
        return messages ?? items ?? []
    }
}

struct MessageAPIModel: Codable {
    let id: Int
    let senderId: Int?
    let content: String?
    let videoId: Int?
    let nomenclatureId: String?
    let createdAt: String?
    let isRead: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case senderId = "sender_id"
        case content
        case videoId = "video_id"
        case nomenclatureId = "nomenclature_id"
        case createdAt = "created_at"
        case isRead = "is_read"
    }
}

struct SendMessageRequest: Codable {
    let recipientId: Int?
    let username: String?
    let content: String
    
    enum CodingKeys: String, CodingKey {
        case recipientId = "recipient_id"
        case username
        case content
    }
    
    init(recipientId: Int, content: String) {
        self.recipientId = recipientId
        self.username = nil
        self.content = content
    }
    
    init(username: String, content: String) {
        self.recipientId = nil
        self.username = username
        self.content = content
    }
}

struct SendMessageResponse: Codable {
    let messageId: Int
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case messageId = "message_id"
        case status
    }
}

struct EmptyResponse: Codable {}
