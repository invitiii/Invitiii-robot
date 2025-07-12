import Foundation

enum UserRole: String, CaseIterable, Codable {
    case host = "host"
    case doorStaff = "door_staff"
    case admin = "admin"
    
    var displayName: String {
        switch self {
        case .host:
            return "Host"
        case .doorStaff:
            return "Door Staff"
        case .admin:
            return "Admin"
        }
    }
}

struct User: Identifiable, Codable {
    let id: String
    var email: String
    var name: String
    var phoneNumber: String?
    var role: UserRole
    var isActive: Bool
    var profileImageURL: String?
    var createdAt: Date
    var lastLoginAt: Date?
    
    // Subscription information (for future payment integration)
    var subscriptionTier: String?
    var subscriptionExpiresAt: Date?
    var eventsCreatedCount: Int
    var monthlyEventLimit: Int
    
    init(id: String = UUID().uuidString,
         email: String,
         name: String,
         phoneNumber: String? = nil,
         role: UserRole = .host,
         isActive: Bool = true,
         profileImageURL: String? = nil,
         subscriptionTier: String? = nil,
         subscriptionExpiresAt: Date? = nil,
         eventsCreatedCount: Int = 0,
         monthlyEventLimit: Int = 5) {
        self.id = id
        self.email = email
        self.name = name
        self.phoneNumber = phoneNumber
        self.role = role
        self.isActive = isActive
        self.profileImageURL = profileImageURL
        self.createdAt = Date()
        self.lastLoginAt = nil
        self.subscriptionTier = subscriptionTier
        self.subscriptionExpiresAt = subscriptionExpiresAt
        self.eventsCreatedCount = eventsCreatedCount
        self.monthlyEventLimit = monthlyEventLimit
    }
    
    // Computed properties
    var hasActiveSubscription: Bool {
        guard let expiryDate = subscriptionExpiresAt else { return false }
        return expiryDate > Date()
    }
    
    var canCreateMoreEvents: Bool {
        return eventsCreatedCount < monthlyEventLimit || hasActiveSubscription
    }
    
    var remainingEvents: Int {
        return max(0, monthlyEventLimit - eventsCreatedCount)
    }
}

// Authentication models
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let name: String
    let phoneNumber: String?
}

struct AuthResponse: Codable {
    let user: User
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
}

// Sample data for previews
extension User {
    static let sampleUser = User(
        email: "sarah@example.com",
        name: "Sarah Al-Mansouri",
        phoneNumber: "+96512345678",
        role: .host,
        subscriptionTier: "Premium",
        subscriptionExpiresAt: Date().addingTimeInterval(86400 * 365),
        eventsCreatedCount: 3,
        monthlyEventLimit: 10
    )
    
    static let sampleDoorStaff = User(
        email: "staff@example.com",
        name: "Ahmed Security",
        phoneNumber: "+96512345679",
        role: .doorStaff
    )
}