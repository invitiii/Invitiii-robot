import Foundation

class WhatsAppService: ObservableObject {
    static let shared = WhatsAppService()
    
    private let whatsAppBaseURL = "https://graph.facebook.com/v18.0"
    private let phoneNumberId = "YOUR_PHONE_NUMBER_ID" // Replace with actual phone number ID
    private let accessToken = "YOUR_ACCESS_TOKEN" // Replace with actual access token
    private let session = URLSession.shared
    
    private init() {}
    
    // MARK: - Send Invitation
    
    func sendInvitation(to guest: Guest, for event: Event, rsvpLink: String) async throws -> WhatsAppMessageResponse {
        let message = createInvitationMessage(guest: guest, event: event, rsvpLink: rsvpLink)
        return try await sendMessage(to: guest.formattedPhoneNumber, message: message)
    }
    
    // MARK: - Send QR Code
    
    func sendQRCode(to guest: Guest, qrCode: String, for event: Event) async throws -> WhatsAppMessageResponse {
        let message = createQRCodeMessage(guest: guest, event: event, qrCode: qrCode)
        return try await sendMessage(to: guest.formattedPhoneNumber, message: message)
    }
    
    // MARK: - Send RSVP Confirmation
    
    func sendRSVPConfirmation(to guest: Guest, status: RSVPStatus, for event: Event) async throws -> WhatsAppMessageResponse {
        let message = createRSVPConfirmationMessage(guest: guest, status: status, event: event)
        return try await sendMessage(to: guest.formattedPhoneNumber, message: message)
    }
    
    // MARK: - Private Methods
    
    private func sendMessage(to phoneNumber: String, message: WhatsAppMessage) async throws -> WhatsAppMessageResponse {
        guard let url = URL(string: "\(whatsAppBaseURL)/\(phoneNumberId)/messages") else {
            throw WhatsAppError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = WhatsAppMessageRequest(
            messaging_product: "whatsapp",
            to: phoneNumber,
            type: message.type,
            template: message.template,
            text: message.text
        )
        
        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            request.httpBody = jsonData
            
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WhatsAppError.invalidResponse
            }
            
            if httpResponse.statusCode == 200 {
                let messageResponse = try JSONDecoder().decode(WhatsAppMessageResponse.self, from: data)
                return messageResponse
            } else {
                let errorResponse = try? JSONDecoder().decode(WhatsAppErrorResponse.self, from: data)
                throw WhatsAppError.apiError(
                    code: httpResponse.statusCode,
                    message: errorResponse?.error.message ?? "Unknown error"
                )
            }
            
        } catch {
            if error is WhatsAppError {
                throw error
            } else {
                throw WhatsAppError.networkError(error.localizedDescription)
            }
        }
    }
    
    private func createInvitationMessage(guest: Guest, event: Event, rsvpLink: String) -> WhatsAppMessage {
        // Use WhatsApp template if available, otherwise fallback to text
        if hasApprovedTemplate() {
            return WhatsAppMessage(
                type: "template",
                template: WhatsAppTemplate(
                    name: "invitation_template",
                    language: WhatsAppLanguage(code: "en"),
                    components: [
                        WhatsAppComponent(
                            type: "body",
                            parameters: [
                                WhatsAppParameter(type: "text", text: guest.name),
                                WhatsAppParameter(type: "text", text: event.name),
                                WhatsAppParameter(type: "text", text: formatDate(event.date)),
                                WhatsAppParameter(type: "text", text: event.time),
                                WhatsAppParameter(type: "text", text: event.venue),
                                WhatsAppParameter(type: "text", text: rsvpLink)
                            ]
                        )
                    ]
                )
            )
        } else {
            // Fallback to text message
            let messageText = """
            🎉 You're Invited! 🎉
            
            Hi \(guest.name),
            
            You're invited to: \(event.name)
            📅 Date: \(formatDate(event.date))
            🕐 Time: \(event.time)
            📍 Venue: \(event.venue)
            
            \(event.description.isEmpty ? "" : "📝 \(event.description)\n")
            Please RSVP: \(rsvpLink)
            
            Looking forward to seeing you there! ✨
            """
            
            return WhatsAppMessage(
                type: "text",
                text: WhatsAppText(body: messageText)
            )
        }
    }
    
    private func createQRCodeMessage(guest: Guest, event: Event, qrCode: String) -> WhatsAppMessage {
        let messageText = """
        🎉 Your Event Pass is Ready! 🎉
        
        Hi \(guest.name),
        
        Thanks for confirming your attendance to \(event.name)!
        
        🎫 Your QR Code: \(qrCode)
        
        Please save this message and show the QR code at the event entrance.
        
        Event Details:
        📅 \(formatDate(event.date)) at \(event.time)
        📍 \(event.venue)
        
        See you there! ✨
        """
        
        return WhatsAppMessage(
            type: "text",
            text: WhatsAppText(body: messageText)
        )
    }
    
    private func createRSVPConfirmationMessage(guest: Guest, status: RSVPStatus, event: Event) -> WhatsAppMessage {
        var messageText: String
        
        switch status {
        case .yes:
            messageText = """
            ✅ RSVP Confirmed!
            
            Hi \(guest.name),
            
            Thank you for confirming your attendance to \(event.name)!
            You'll receive your QR code entry pass shortly.
            
            Event Details:
            📅 \(formatDate(event.date)) at \(event.time)
            📍 \(event.venue)
            
            We can't wait to see you there! 🎉
            """
            
        case .no:
            messageText = """
            Thanks for your response
            
            Hi \(guest.name),
            
            We received your RSVP for \(event.name).
            We're sorry you can't make it, but we understand.
            
            Hope to see you at future events! 💙
            """
            
        case .maybe:
            messageText = """
            Thanks for your response
            
            Hi \(guest.name),
            
            We received your "maybe" RSVP for \(event.name).
            We hope you can make it!
            
            Event Details:
            📅 \(formatDate(event.date)) at \(event.time)
            📍 \(event.venue)
            
            Let us know if your plans change! ✨
            """
            
        case .pending:
            messageText = "RSVP status update"
        }
        
        return WhatsAppMessage(
            type: "text",
            text: WhatsAppText(body: messageText)
        )
    }
    
    private func hasApprovedTemplate() -> Bool {
        // In a real implementation, check if templates are approved
        return false
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}

// MARK: - WhatsApp Message Models

struct WhatsAppMessageRequest: Codable {
    let messaging_product: String
    let to: String
    let type: String
    let template: WhatsAppTemplate?
    let text: WhatsAppText?
}

struct WhatsAppMessage {
    let type: String
    let template: WhatsAppTemplate?
    let text: WhatsAppText?
    
    init(type: String, template: WhatsAppTemplate? = nil, text: WhatsAppText? = nil) {
        self.type = type
        self.template = template
        self.text = text
    }
}

struct WhatsAppTemplate: Codable {
    let name: String
    let language: WhatsAppLanguage
    let components: [WhatsAppComponent]
}

struct WhatsAppLanguage: Codable {
    let code: String
}

struct WhatsAppComponent: Codable {
    let type: String
    let parameters: [WhatsAppParameter]
}

struct WhatsAppParameter: Codable {
    let type: String
    let text: String
}

struct WhatsAppText: Codable {
    let body: String
}

struct WhatsAppMessageResponse: Codable {
    let messaging_product: String
    let contacts: [WhatsAppContact]
    let messages: [WhatsAppMessageStatus]
}

struct WhatsAppContact: Codable {
    let input: String
    let wa_id: String
}

struct WhatsAppMessageStatus: Codable {
    let id: String
}

struct WhatsAppErrorResponse: Codable {
    let error: WhatsAppErrorDetail
}

struct WhatsAppErrorDetail: Codable {
    let message: String
    let type: String
    let code: Int
    let error_subcode: Int?
    let fbtrace_id: String?
}

// MARK: - WhatsApp Error Types

enum WhatsAppError: LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(code: Int, message: String)
    case networkError(String)
    case templateNotApproved
    case invalidPhoneNumber
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid WhatsApp API URL"
        case .invalidResponse:
            return "Invalid response from WhatsApp API"
        case .apiError(let code, let message):
            return "WhatsApp API error (\(code)): \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .templateNotApproved:
            return "WhatsApp message template not approved"
        case .invalidPhoneNumber:
            return "Invalid phone number format"
        }
    }
}

// MARK: - Template Configuration

struct WhatsAppTemplateConfig {
    static let invitationTemplate = """
    🎉 You're Invited! 🎉
    
    Hi {{1}},
    
    You're invited to: {{2}}
    📅 Date: {{3}}
    🕐 Time: {{4}}
    📍 Venue: {{5}}
    
    Please RSVP: {{6}}
    
    Looking forward to seeing you there! ✨
    """
    
    static let qrCodeTemplate = """
    🎫 Your Event Pass is Ready!
    
    Hi {{1}},
    
    Thanks for confirming! Your QR code for {{2}} is: {{3}}
    
    Show this at the entrance on {{4}}.
    
    See you there! 🎉
    """
}