//
//  ChatAPIModels.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import Foundation
struct ChatListResponse: Codable {
    let chats: [ChatAPIModel]?
    let items: [ChatAPIModel]?
    
    var allChats: [ChatAPIModel] {
        return chats ?? items ?? []
    }
}

struct ChatAPIModel: Codable {
    let id: String
    let recipientId: String?
    let recipientName: String?
    let recipientAvatar: String?
    let recipientVerified: Bool?
    let lastMessage: MessageAPIModel?
    let unreadCount: Int?
    let isArchived: Bool?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case recipientId = "recipient_id"
        case recipientName = "recipient_name"
        case recipientAvatar = "recipient_avatar"
        case recipientVerified = "recipient_verified"
        case lastMessage = "last_message"
        case unreadCount = "unread_count"
        case isArchived = "is_archived"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
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
    let id: String
    let chatId: String?
    let senderId: String?
    let content: String?
    let type: String?
    let mediaUrl: String?
    let replyToId: String?
    let isRead: Bool?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case chatId = "chat_id"
        case senderId = "sender_id"
        case content
        case type
        case mediaUrl = "media_url"
        case replyToId = "reply_to_id"
        case isRead = "is_read"
        case createdAt = "created_at"
    }
}
struct SendMessageRequest: Codable {
    let chatId: String
    let content: String
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case content
        case type
    }
}