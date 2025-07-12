import Foundation

class APIService: ObservableObject {
    static let shared = APIService()
    
    private let baseURL = "https://api.invitii.com" // Replace with actual API URL
    private let session = URLSession.shared
    
    private init() {}
    
    // MARK: - Generic API Request Method
    
    private func performRequest<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Data? = nil,
        headers: [String: String] = [:],
        responseType: T.Type
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        // Set default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add custom headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            let decodedResponse = try JSONDecoder().decode(responseType, from: data)
            return decodedResponse
            
        } catch {
            if error is APIError {
                throw error
            } else {
                throw APIError.networkError(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Authentication API
    
    func login(email: String, password: String) async throws -> AuthResponse {
        let loginRequest = LoginRequest(email: email, password: password)
        let body = try JSONEncoder().encode(loginRequest)
        
        return try await performRequest(
            endpoint: "/auth/login",
            method: .POST,
            body: body,
            responseType: AuthResponse.self
        )
    }
    
    func register(email: String, password: String, name: String, phoneNumber: String?) async throws -> AuthResponse {
        let registerRequest = RegisterRequest(
            email: email,
            password: password,
            name: name,
            phoneNumber: phoneNumber
        )
        let body = try JSONEncoder().encode(registerRequest)
        
        return try await performRequest(
            endpoint: "/auth/register",
            method: .POST,
            body: body,
            responseType: AuthResponse.self
        )
    }
    
    // MARK: - Event API
    
    func createEvent(_ event: Event, authHeaders: [String: String]) async throws -> Event {
        let body = try JSONEncoder().encode(event)
        
        return try await performRequest(
            endpoint: "/events",
            method: .POST,
            body: body,
            headers: authHeaders,
            responseType: Event.self
        )
    }
    
    func getEvents(authHeaders: [String: String]) async throws -> [Event] {
        return try await performRequest(
            endpoint: "/events",
            method: .GET,
            headers: authHeaders,
            responseType: [Event].self
        )
    }
    
    func updateEvent(_ event: Event, authHeaders: [String: String]) async throws -> Event {
        let body = try JSONEncoder().encode(event)
        
        return try await performRequest(
            endpoint: "/events/\(event.id)",
            method: .PUT,
            body: body,
            headers: authHeaders,
            responseType: Event.self
        )
    }
    
    func deleteEvent(eventId: String, authHeaders: [String: String]) async throws {
        let _: EmptyResponse = try await performRequest(
            endpoint: "/events/\(eventId)",
            method: .DELETE,
            headers: authHeaders,
            responseType: EmptyResponse.self
        )
    }
    
    // MARK: - Guest API
    
    func addGuest(_ guest: Guest, authHeaders: [String: String]) async throws -> Guest {
        let body = try JSONEncoder().encode(guest)
        
        return try await performRequest(
            endpoint: "/guests",
            method: .POST,
            body: body,
            headers: authHeaders,
            responseType: Guest.self
        )
    }
    
    func getGuestsForEvent(eventId: String, authHeaders: [String: String]) async throws -> [Guest] {
        return try await performRequest(
            endpoint: "/events/\(eventId)/guests",
            method: .GET,
            headers: authHeaders,
            responseType: [Guest].self
        )
    }
    
    func removeGuest(guestId: String, authHeaders: [String: String]) async throws {
        let _: EmptyResponse = try await performRequest(
            endpoint: "/guests/\(guestId)",
            method: .DELETE,
            headers: authHeaders,
            responseType: EmptyResponse.self
        )
    }
    
    // MARK: - RSVP API
    
    func getRSVPsForEvent(eventId: String, authHeaders: [String: String]) async throws -> [RSVP] {
        return try await performRequest(
            endpoint: "/events/\(eventId)/rsvps",
            method: .GET,
            headers: authHeaders,
            responseType: [RSVP].self
        )
    }
    
    func submitRSVP(_ rsvp: RSVP) async throws -> RSVP {
        let body = try JSONEncoder().encode(rsvp)
        
        return try await performRequest(
            endpoint: "/rsvp",
            method: .POST,
            body: body,
            responseType: RSVP.self
        )
    }
    
    func validateQRCode(_ qrCode: String, eventId: String, authHeaders: [String: String]) async throws -> QRValidationResponse {
        let request = QRValidationRequest(qrCode: qrCode, eventId: eventId)
        let body = try JSONEncoder().encode(request)
        
        return try await performRequest(
            endpoint: "/qr/validate",
            method: .POST,
            body: body,
            headers: authHeaders,
            responseType: QRValidationResponse.self
        )
    }
    
    func markQRCodeAsUsed(rsvpId: String, authHeaders: [String: String]) async throws -> RSVP {
        let request = QRUseRequest(rsvpId: rsvpId)
        let body = try JSONEncoder().encode(request)
        
        return try await performRequest(
            endpoint: "/qr/use",
            method: .POST,
            body: body,
            headers: authHeaders,
            responseType: RSVP.self
        )
    }
    
    // MARK: - File Upload API
    
    func uploadEventCover(eventId: String, imageData: Data, authHeaders: [String: String]) async throws -> MediaUploadResponse {
        guard let url = URL(string: "\(baseURL)/events/\(eventId)/cover") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Add auth headers
        for (key, value) in authHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let httpBody = createMultipartBody(boundary: boundary, data: imageData, fileName: "cover.jpg", mimeType: "image/jpeg")
        request.httpBody = httpBody
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(MediaUploadResponse.self, from: data)
    }
    
    private func createMultipartBody(boundary: String, data: Data, fileName: String, mimeType: String) -> Data {
        var body = Data()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        body.append(boundaryPrefix.data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
}

// MARK: - Supporting Types

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case networkError(String)
    case decodingError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .decodingError(let message):
            return "Decoding error: \(message)"
        }
    }
}

// MARK: - Request/Response Models

struct EmptyResponse: Codable {}

struct QRValidationRequest: Codable {
    let qrCode: String
    let eventId: String
}

struct QRValidationResponse: Codable {
    let isValid: Bool
    let isAlreadyUsed: Bool
    let guestName: String?
    let rsvpId: String?
    let errorMessage: String?
}

struct QRUseRequest: Codable {
    let rsvpId: String
}

struct MediaUploadResponse: Codable {
    let url: String
    let fileName: String
    let size: Int
}