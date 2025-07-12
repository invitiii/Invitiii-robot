import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var accessToken: String?
    private var refreshToken: String?
    
    init() {
        checkAuthenticationStatus()
    }
    
    // MARK: - Authentication Methods
    
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        let request = LoginRequest(email: email, password: password)
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // For demo purposes, accept any email/password
            let user = User(
                email: email,
                name: email.components(separatedBy: "@").first?.capitalized ?? "User",
                phoneNumber: "+96512345678",
                role: .host
            )
            
            self.currentUser = user
            self.isAuthenticated = true
            self.isLoading = false
            self.accessToken = "demo_access_token"
            self.refreshToken = "demo_refresh_token"
            
            // Save to UserDefaults for persistence
            self.saveAuthenticationState()
        }
    }
    
    func register(email: String, password: String, name: String = "", phoneNumber: String? = nil) {
        isLoading = true
        errorMessage = nil
        
        let request = RegisterRequest(
            email: email,
            password: password,
            name: name.isEmpty ? email.components(separatedBy: "@").first?.capitalized ?? "User" : name,
            phoneNumber: phoneNumber
        )
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let user = User(
                email: email,
                name: request.name,
                phoneNumber: phoneNumber,
                role: .host
            )
            
            self.currentUser = user
            self.isAuthenticated = true
            self.isLoading = false
            self.accessToken = "demo_access_token"
            self.refreshToken = "demo_refresh_token"
            
            // Save to UserDefaults for persistence
            self.saveAuthenticationState()
        }
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        accessToken = nil
        refreshToken = nil
        errorMessage = nil
        
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: "isAuthenticated")
        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.removeObject(forKey: "accessToken")
    }
    
    // MARK: - Private Methods
    
    private func checkAuthenticationStatus() {
        let isAuth = UserDefaults.standard.bool(forKey: "isAuthenticated")
        
        if isAuth,
           let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData),
           let token = UserDefaults.standard.string(forKey: "accessToken") {
            
            self.currentUser = user
            self.isAuthenticated = true
            self.accessToken = token
        }
    }
    
    private func saveAuthenticationState() {
        UserDefaults.standard.set(true, forKey: "isAuthenticated")
        UserDefaults.standard.set(accessToken, forKey: "accessToken")
        
        if let user = currentUser,
           let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "currentUser")
        }
    }
    
    // MARK: - API Headers
    
    var authHeaders: [String: String] {
        var headers = ["Content-Type": "application/json"]
        if let token = accessToken {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }
}