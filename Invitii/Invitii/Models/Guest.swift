import Foundation

struct Guest: Identifiable, Codable {
    let id: String
    var name: String
    var phoneNumber: String
    var email: String?
    var eventId: String
    var rsvpLink: String?
    var qrCode: String?
    var hasOpened: Bool
    var invitationSentAt: Date?
    var createdAt: Date
    
    // Computed properties
    var formattedPhoneNumber: String {
        // Format phone number for WhatsApp (remove spaces, add country code if needed)
        let cleaned = phoneNumber.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
        
        // If it doesn't start with +, assume it's a GCC number and add +965 (Kuwait)
        if !cleaned.hasPrefix("+") {
            return "+965\(cleaned)"
        }
        return cleaned
    }
    
    var isValidPhoneNumber: Bool {
        let phoneRegex = "^\\+[1-9]\\d{1,14}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: formattedPhoneNumber)
    }
    
    init(id: String = UUID().uuidString,
         name: String,
         phoneNumber: String,
         email: String? = nil,
         eventId: String,
         rsvpLink: String? = nil,
         qrCode: String? = nil,
         hasOpened: Bool = false,
         invitationSentAt: Date? = nil) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
        self.eventId = eventId
        self.rsvpLink = rsvpLink
        self.qrCode = qrCode
        self.hasOpened = hasOpened
        self.invitationSentAt = invitationSentAt
        self.createdAt = Date()
    }
}

// CSV Import structure
struct GuestImportData {
    let name: String
    let phoneNumber: String
    let email: String?
    
    static func parseCSV(_ csvContent: String) -> [GuestImportData] {
        var guests: [GuestImportData] = []
        let lines = csvContent.components(separatedBy: .newlines)
        
        // Skip header row if present
        let dataLines = lines.dropFirst()
        
        for line in dataLines {
            let columns = line.components(separatedBy: ",")
            if columns.count >= 2 {
                let name = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let phone = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
                let email = columns.count > 2 ? columns[2].trimmingCharacters(in: .whitespacesAndNewlines) : nil
                
                if !name.isEmpty && !phone.isEmpty {
                    guests.append(GuestImportData(name: name, phoneNumber: phone, email: email))
                }
            }
        }
        
        return guests
    }
}

// Sample data for previews
extension Guest {
    static let sampleGuests = [
        Guest(
            name: "Ahmed Al-Rashid",
            phoneNumber: "+96512345678",
            email: "ahmed@example.com",
            eventId: "event123",
            hasOpened: true,
            invitationSentAt: Date().addingTimeInterval(-86400)
        ),
        Guest(
            name: "Fatima Al-Zahra",
            phoneNumber: "+96512345679",
            email: "fatima@example.com",
            eventId: "event123",
            hasOpened: false,
            invitationSentAt: Date().addingTimeInterval(-86400)
        ),
        Guest(
            name: "Mohammed Al-Kuwaiti",
            phoneNumber: "+96512345680",
            eventId: "event123",
            hasOpened: true,
            invitationSentAt: Date().addingTimeInterval(-43200)
        )
    ]
}