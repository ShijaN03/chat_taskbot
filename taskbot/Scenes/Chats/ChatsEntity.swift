//
//  ChatsEntity.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import Foundation

struct ChatEntity: Codable {
    let id: Int
    let recipientId: Int
    let recipientName: String
    let recipientAvatarURL: String?
    let isVerified: Bool
    let isOnline: Bool
    let lastMessage: ChatMessage?
    let unreadCount: Int
    let updatedAt: Date
    let isArchived: Bool
}

struct ChatMessage: Codable {
    let id: Int
    let senderId: Int
    let content: String
    let type: ChatMessageType
    let createdAt: Date
    let isRead: Bool
}

enum ChatMessageType: String, Codable {
    case text
    case photo
    case video
    case voice
    case location
    case publication
    
    var displayPrefix: String {
        switch self {
        case .text:
            return ""
        case .photo:
            return "Отправил фото"
        case .video:
            return "Отправил видео"
        case .voice:
            return "Голосовое сообщение"
        case .location:
            return "Отправил локацию"
        case .publication:
            return "Отправил публикацию"
        }
    }
}