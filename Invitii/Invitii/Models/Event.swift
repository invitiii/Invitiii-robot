import Foundation

struct Event: Identifiable, Codable {
    let id: String
    var name: String
    var date: Date
    var time: String
    var venue: String
    var description: String
    var coverImageURL: String?
    var coverVideoURL: String?
    var hostId: String
    var guests: [Guest]
    var rsvps: [RSVP]
    var createdAt: Date
    var updatedAt: Date
    
    // Computed properties for RSVP statistics
    var totalGuests: Int {
        return guests.count
    }
    
    var confirmedCount: Int {
        return rsvps.filter { $0.status == .yes }.count
    }
    
    var declinedCount: Int {
        return rsvps.filter { $0.status == .no }.count
    }
    
    var maybeCount: Int {
        return rsvps.filter { $0.status == .maybe }.count
    }
    
    var pendingCount: Int {
        return totalGuests - confirmedCount - declinedCount - maybeCount
    }
    
    var rsvpRate: Double {
        guard totalGuests > 0 else { return 0 }
        return Double(confirmedCount + declinedCount + maybeCount) / Double(totalGuests) * 100
    }
    
    init(id: String = UUID().uuidString,
         name: String,
         date: Date,
         time: String,
         venue: String,
         description: String = "",
         coverImageURL: String? = nil,
         coverVideoURL: String? = nil,
         hostId: String,
         guests: [Guest] = [],
         rsvps: [RSVP] = []) {
        self.id = id
        self.name = name
        self.date = date
        self.time = time
        self.venue = venue
        self.description = description
        self.coverImageURL = coverImageURL
        self.coverVideoURL = coverVideoURL
        self.hostId = hostId
        self.guests = guests
        self.rsvps = rsvps
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// Sample data for previews and testing
extension Event {
    static let sampleEvent = Event(
        name: "Sarah's Wedding",
        date: Date().addingTimeInterval(86400 * 30), // 30 days from now
        time: "18:00",
        venue: "The Grand Hotel, Kuwait City",
        description: "Join us for a magical evening as we celebrate our special day!",
        hostId: "host123"
    )
    
    static let sampleEvents = [
        Event(
            name: "Sarah's Wedding",
            date: Date().addingTimeInterval(86400 * 30),
            time: "18:00",
            venue: "The Grand Hotel, Kuwait City",
            hostId: "host123"
        ),
        Event(
            name: "Corporate Gala",
            date: Date().addingTimeInterval(86400 * 45),
            time: "19:30",
            venue: "Four Seasons Hotel, Riyadh",
            hostId: "host123"
        ),
        Event(
            name: "Birthday Celebration",
            date: Date().addingTimeInterval(86400 * 15),
            time: "15:00",
            venue: "Private Villa, Dubai",
            hostId: "host123"
        )
    ]
}