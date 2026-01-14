//
//  UserAPIModels.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import Foundation

struct UserSearchResponse: Codable {
    let total: Int?
    let offset: Int?
    let limit: Int?
    let count: Int?
    let filter: UserSearchFilter?
    let items: [UserAPIModel]?
    
    var allUsers: [UserAPIModel] {
        return items ?? []
    }
}

struct UserSearchFilter: Codable {
}

struct UserAPIModel: Codable {
    let id: Int
    let name: String?
    let telegramUsername: String?
    let avatar: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, avatar
        case telegramUsername = "telegram_username"
    }
}

struct UserProfileResponse: Codable {
    let id: Int
    let name: String?
    let telegramUsername: String?
    let avatar: String?
    let bio: String?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, avatar, bio
        case telegramUsername = "telegram_username"
        case createdAt = "created_at"
    }
}
