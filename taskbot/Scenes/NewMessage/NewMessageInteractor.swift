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
                let users = apiUsers.map { mapToEntity($0) }
                
                await MainActor.run {
                    if users.isEmpty {
                        // Fallback to mock data if API returns empty
                        presenter?.didFetchRecommendedUsers(createMockUsers())
                    } else {
                        presenter?.didFetchRecommendedUsers(users)
                    }
                }
            } catch {
                // Fallback to mock data on error
                await MainActor.run {
                    presenter?.didFetchRecommendedUsers(createMockUsers())
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
                let users = apiUsers.map { mapToEntity($0) }
                
                await MainActor.run {
                    if users.isEmpty {
                        // Fallback to local filtering of mock data
                        let mockUsers = createMockUsers()
                        let filtered = mockUsers.filter {
                            $0.username.lowercased().contains(query.lowercased()) ||
                            ($0.displayName?.lowercased().contains(query.lowercased()) ?? false)
                        }
                        presenter?.didSearchUsers(filtered)
                    } else {
                        presenter?.didSearchUsers(users)
                    }
                }
            } catch {
                // Fallback to local filtering on error
                await MainActor.run {
                    let mockUsers = createMockUsers()
                    let filtered = mockUsers.filter {
                        $0.username.lowercased().contains(query.lowercased()) ||
                        ($0.displayName?.lowercased().contains(query.lowercased()) ?? false)
                    }
                    presenter?.didSearchUsers(filtered)
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
            UserEntity(
                id: "1",
                username: "anna_smile",
                displayName: "Анна",
                avatarURL: "https://picsum.photos/seed/anna/100/100",
                accountType: .personal,
                isVerified: false
            ),
            UserEntity(
                id: "2",
                username: "photo_studio_pro",
                displayName: "Фотостудия ProShot",
                avatarURL: "https://picsum.photos/seed/studio/100/100",
                accountType: .business,
                isVerified: true
            ),
            UserEntity(
                id: "3",
                username: "travel_maria",
                displayName: "Мария",
                avatarURL: "https://picsum.photos/seed/maria/100/100",
                accountType: .creator,
                isVerified: false
            ),
            UserEntity(
                id: "4",
                username: "coffee_house",
                displayName: "Coffee House",
                avatarURL: "https://picsum.photos/seed/coffee/100/100",
                accountType: .business,
                isVerified: true
            ),
            UserEntity(
                id: "5",
                username: "dmitry_dev",
                displayName: "Дмитрий",
                avatarURL: "https://picsum.photos/seed/dmitry/100/100",
                accountType: .personal,
                isVerified: false
            )
        ]
    }
}