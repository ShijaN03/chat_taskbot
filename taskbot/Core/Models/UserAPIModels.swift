//
//  UserAPIModels.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import Foundation

struct UserSearchResponse: Codable {
    let users: [UserAPIModel]?
    let items: [UserAPIModel]?
    
    var allUsers: [UserAPIModel] {
        return users ?? items ?? []
    }
}

struct UserAPIModel: Codable {
    let id: String
    let username: String?
    let displayName: String?
    let avatar: String?
    let avatarUrl: String?
    let accountType: String?
    let isVerified: Bool?
    let bio: String?
    let followersCount: Int?
    let followingCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case displayName = "display_name"
        case avatar
        case avatarUrl = "avatar_url"
        case accountType = "account_type"
        case isVerified = "is_verified"
        case bio
        case followersCount = "followers_count"
        case followingCount = "following_count"
    }
    
    var resolvedAvatarURL: String? {
        return avatarUrl ?? avatar
    }
}

struct UserProfileResponse: Codable {
    let id: String
    let username: String?
    let displayName: String?
    let avatar: String?
    let avatarUrl: String?
    let accountType: String?
    let isVerified: Bool?
    let bio: String?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case displayName = "display_name"
        case avatar
        case avatarUrl = "avatar_url"
        case accountType = "account_type"
        case isVerified = "is_verified"
        case bio
        case createdAt = "created_at"
    }
}
