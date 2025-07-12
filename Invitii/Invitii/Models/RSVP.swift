import Foundation

enum RSVPStatus: String, CaseIterable, Codable {
    case yes = "yes"
    case no = "no"
    case maybe = "maybe"
    case pending = "pending"
    
    var displayName: String {
        switch self {
        case .yes:
            return "Yes"
        case .no:
            return "No"
        case .maybe:
            return "Maybe"
        case .pending:
            return "Pending"
        }
    }
    
    var color: String {
        switch self {
        case .yes:
            return "green"
        case .no:
            return "red"
        case .maybe:
            return "orange"
        case .pending:
            return "gray"
        }
    }
}

struct RSVP: Identifiable, Codable {
    let id: String
    let guestId: String
    let eventId: String
    var status: RSVPStatus
    var message: String?
    var qrCode: String?
    var qrCodeUsed: Bool
    var qrCodeUsedAt: Date?
    var respondedAt: Date
    var createdAt: Date
    
    // Guest information (denormalized for easier querying)
    var guestName: String
    var guestPhone: String
    
    init(id: String = UUID().uuidString,
         guestId: String,
         eventId: String,
         status: RSVPStatus,
         message: String? = nil,
         qrCode: String? = nil,
         qrCodeUsed: Bool = false,
         qrCodeUsedAt: Date? = nil,
         guestName: String,
         guestPhone: String) {
        self.id = id
        self.guestId = guestId
        self.eventId = eventId
        self.status = status
        self.message = message
        self.qrCode = qrCode
        self.qrCodeUsed = qrCodeUsed
        self.qrCodeUsedAt = qrCodeUsedAt
        self.respondedAt = Date()
        self.createdAt = Date()
        self.guestName = guestName
        self.guestPhone = guestPhone
    }
}

// QR Code Scan Result
struct QRScanResult {
    let rsvpId: String
    let eventId: String
    let guestName: String
    let isValid: Bool
    let isAlreadyUsed: Bool
    let errorMessage: String?
    
    static func success(rsvpId: String, eventId: String, guestName: String) -> QRScanResult {
        return QRScanResult(
            rsvpId: rsvpId,
            eventId: eventId,
            guestName: guestName,
            isValid: true,
            isAlreadyUsed: false,
            errorMessage: nil
        )
    }
    
    static func alreadyUsed(rsvpId: String, eventId: String, guestName: String) -> QRScanResult {
        return QRScanResult(
            rsvpId: rsvpId,
            eventId: eventId,
            guestName: guestName,
            isValid: false,
            isAlreadyUsed: true,
            errorMessage: "QR code has already been used"
        )
    }
    
    static func invalid(errorMessage: String) -> QRScanResult {
        return QRScanResult(
            rsvpId: "",
            eventId: "",
            guestName: "",
            isValid: false,
            isAlreadyUsed: false,
            errorMessage: errorMessage
        )
    }
}

// Sample data for previews
extension RSVP {
    static let sampleRSVPs = [
        RSVP(
            guestId: "guest1",
            eventId: "event123",
            status: .yes,
            message: "Can't wait to celebrate with you!",
            qrCode: "QR123456",
            guestName: "Ahmed Al-Rashid",
            guestPhone: "+96512345678"
        ),
        RSVP(
            guestId: "guest2",
            eventId: "event123",
            status: .no,
            message: "Unfortunately won't be able to make it",
            guestName: "Fatima Al-Zahra",
            guestPhone: "+96512345679"
        ),
        RSVP(
            guestId: "guest3",
            eventId: "event123",
            status: .maybe,
            message: "Will try my best to attend",
            guestName: "Mohammed Al-Kuwaiti",
            guestPhone: "+96512345680"
        )
    ]
}