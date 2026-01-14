//
//  NewMessageInteractor.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import Foundation

final class NewMessageInteractor: NewMessageInteractorInputProtocol {
    
    weak var presenter: NewMessageInteractorOutputProtocol?
    private let worker: NewMessageWorkerProtocol
    
    init(worker: NewMessageWorkerProtocol = NewMessageWorker()) {
        self.worker = worker
    }
    
    func fetchRecommendedUsers() {
        Task {
            do {
                let apiUsers = try await worker.getRecommendedUsers()
                print("👥 Loaded \(apiUsers.count) recommended users")
                let users = apiUsers.map { mapToEntity($0) }
                
                await MainActor.run {
                    presenter?.didFetchRecommendedUsers(users)
                }
            } catch {
                print("❌ Failed to load recommended users: \(error.localizedDescription)")
                await MainActor.run {
                    presenter?.didFetchRecommendedUsers([])
                }
            }
        }
    }
    
    func searchUsers(with query: String) {
        guard !query.isEmpty else {
            fetchRecommendedUsers()
            return
        }
        
        Task {
            do {
                let apiUsers = try await worker.searchUsers(query: query)
                print("🔍 Found \(apiUsers.count) users for query: \(query)")
                let users = apiUsers.map { mapToEntity($0) }
                
                await MainActor.run {
                    presenter?.didSearchUsers(users)
                }
            } catch {
                print("❌ Search failed: \(error.localizedDescription)")
                await MainActor.run {
                    presenter?.didSearchUsers([])
                }
            }
        }
    }
    
    private func mapToEntity(_ api: UserAPIModel) -> UserEntity {
        let accountType: AccountType
        switch api.accountType?.lowercased() {
        case "business":
            accountType = .business
        case "creator":
            accountType = .creator
        default:
            accountType = .personal
        }
        
        return UserEntity(
            id: api.id,
            username: api.username ?? "user",
            displayName: api.displayName,
            avatarURL: api.resolvedAvatarURL,
            accountType: accountType,
            isVerified: api.isVerified ?? false
        )
    }
    
    private func createMockUsers() -> [UserEntity] {
        return [
            // Target user for testing
            UserEntity(
                id: "2",
                username: "natfullin",
                displayName: "Natfullin",
                avatarURL: "https://picsum.photos/seed/natfullin/100/100",
                accountType: .personal,
                isVerified: true
            ),
            UserEntity(
                id: "1",
                username: "anna_smile",
                displayName: "Анна",
                avatarURL: "https://picsum.photos/seed/anna/100/100",
                accountType: .personal,
                isVerified: false
            ),
            UserEntity(
                id: "3",
                username: "photo_studio_pro",
                displayName: "Фотостудия ProShot",
                avatarURL: "https://picsum.photos/seed/studio/100/100",
                accountType: .business,
                isVerified: true
            ),
            UserEntity(
                id: "4",
                username: "travel_maria",
                displayName: "Мария",
                avatarURL: "https://picsum.photos/seed/maria/100/100",
                accountType: .creator,
                isVerified: false
            ),
            UserEntity(
                id: "5",
                username: "coffee_house",
                displayName: "Coffee House",
                avatarURL: "https://picsum.photos/seed/coffee/100/100",
                accountType: .business,
                isVerified: true
            )
        ]
    }
}