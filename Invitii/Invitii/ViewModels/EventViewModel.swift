import Foundation
import SwiftUI

@MainActor
class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var selectedEvent: Event?
    @Published var guests: [Guest] = []
    @Published var rsvps: [RSVP] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Event creation
    @Published var newEventName = ""
    @Published var newEventDate = Date()
    @Published var newEventTime = ""
    @Published var newEventVenue = ""
    @Published var newEventDescription = ""
    @Published var selectedCoverImage: UIImage?
    
    // Guest management
    @Published var newGuestName = ""
    @Published var newGuestPhone = ""
    @Published var newGuestEmail = ""
    @Published var importedGuests: [GuestImportData] = []
    
    // Statistics
    @Published var totalInvitesSent = 0
    @Published var totalRSVPs = 0
    @Published var averageResponseTime: TimeInterval = 0
    
    init() {
        loadSampleData()
    }
    
    // MARK: - Event Management
    
    func createEvent(hostId: String) {
        isLoading = true
        errorMessage = nil
        
        let newEvent = Event(
            name: newEventName,
            date: newEventDate,
            time: newEventTime,
            venue: newEventVenue,
            description: newEventDescription,
            hostId: hostId
        )
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.events.append(newEvent)
            self.selectedEvent = newEvent
            self.isLoading = false
            self.clearEventForm()
        }
    }
    
    func updateEvent(_ event: Event) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
            if selectedEvent?.id == event.id {
                selectedEvent = event
            }
        }
    }
    
    func deleteEvent(_ event: Event) {
        events.removeAll { $0.id == event.id }
        if selectedEvent?.id == event.id {
            selectedEvent = nil
        }
    }
    
    func selectEvent(_ event: Event) {
        selectedEvent = event
        loadGuestsForEvent(event.id)
        loadRSVPsForEvent(event.id)
    }
    
    // MARK: - Guest Management
    
    func addGuest(to eventId: String) {
        guard !newGuestName.isEmpty && !newGuestPhone.isEmpty else { return }
        
        let newGuest = Guest(
            name: newGuestName,
            phoneNumber: newGuestPhone,
            email: newGuestEmail.isEmpty ? nil : newGuestEmail,
            eventId: eventId
        )
        
        guests.append(newGuest)
        updateEventGuestList(eventId: eventId)
        clearGuestForm()
    }
    
    func importGuestsFromCSV(_ csvContent: String, to eventId: String) {
        let guestData = GuestImportData.parseCSV(csvContent)
        
        for data in guestData {
            let guest = Guest(
                name: data.name,
                phoneNumber: data.phoneNumber,
                email: data.email,
                eventId: eventId
            )
            guests.append(guest)
        }
        
        updateEventGuestList(eventId: eventId)
        importedGuests = guestData
    }
    
    func removeGuest(_ guest: Guest) {
        guests.removeAll { $0.id == guest.id }
        if let eventId = selectedEvent?.id {
            updateEventGuestList(eventId: eventId)
        }
    }
    
    // MARK: - Invitation Management
    
    func sendInvitations(for event: Event) {
        isLoading = true
        
        // Simulate sending WhatsApp invitations
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let eventGuests = self.guests.filter { $0.eventId == event.id }
            
            for guest in eventGuests {
                if let index = self.guests.firstIndex(where: { $0.id == guest.id }) {
                    self.guests[index].invitationSentAt = Date()
                    self.guests[index].rsvpLink = "https://invitii.com/rsvp/\(event.id)/\(guest.id)"
                }
            }
            
            self.isLoading = false
            self.totalInvitesSent += eventGuests.count
        }
    }
    
    // MARK: - RSVP Management
    
    func loadRSVPsForEvent(_ eventId: String) {
        // Simulate loading RSVPs
        rsvps = RSVP.sampleRSVPs.filter { $0.eventId == eventId }
    }
    
    func processRSVP(guestId: String, eventId: String, status: RSVPStatus, message: String? = nil) {
        guard let guest = guests.first(where: { $0.id == guestId }) else { return }
        
        let rsvp = RSVP(
            guestId: guestId,
            eventId: eventId,
            status: status,
            message: message,
            qrCode: status == .yes ? generateQRCode() : nil,
            guestName: guest.name,
            guestPhone: guest.phoneNumber
        )
        
        // Remove existing RSVP for this guest if any
        rsvps.removeAll { $0.guestId == guestId }
        rsvps.append(rsvp)
        
        updateEventRSVPList(eventId: eventId)
        
        // Send QR code via WhatsApp if confirmed
        if status == .yes {
            sendQRCodeToGuest(guest: guest, qrCode: rsvp.qrCode!)
        }
    }
    
    // MARK: - QR Code Management
    
    func validateQRCode(_ qrCode: String) -> QRScanResult {
        // Find RSVP by QR code
        guard let rsvp = rsvps.first(where: { $0.qrCode == qrCode }) else {
            return .invalid(errorMessage: "Invalid QR code")
        }
        
        // Check if already used
        if rsvp.qrCodeUsed {
            return .alreadyUsed(rsvpId: rsvp.id, eventId: rsvp.eventId, guestName: rsvp.guestName)
        }
        
        return .success(rsvpId: rsvp.id, eventId: rsvp.eventId, guestName: rsvp.guestName)
    }
    
    func markQRCodeAsUsed(_ rsvpId: String) {
        if let index = rsvps.firstIndex(where: { $0.id == rsvpId }) {
            rsvps[index].qrCodeUsed = true
            rsvps[index].qrCodeUsedAt = Date()
        }
    }
    
    // MARK: - Data Export
    
    func exportGuestListToCSV(for event: Event) -> String {
        var csvContent = "Name,Phone,Email,RSVP Status,Response Time\n"
        
        let eventGuests = guests.filter { $0.eventId == event.id }
        
        for guest in eventGuests {
            let rsvp = rsvps.first { $0.guestId == guest.id }
            let status = rsvp?.status.displayName ?? "Pending"
            let responseTime = rsvp?.respondedAt.formatted() ?? "N/A"
            
            csvContent += "\(guest.name),\(guest.phoneNumber),\(guest.email ?? ""),\(status),\(responseTime)\n"
        }
        
        return csvContent
    }
    
    // MARK: - Private Methods
    
    private func loadSampleData() {
        events = Event.sampleEvents
        guests = Guest.sampleGuests
        rsvps = RSVP.sampleRSVPs
    }
    
    private func loadGuestsForEvent(_ eventId: String) {
        // In a real app, this would fetch from API
        guests = Guest.sampleGuests.filter { $0.eventId == eventId }
    }
    
    private func updateEventGuestList(eventId: String) {
        if let index = events.firstIndex(where: { $0.id == eventId }) {
            events[index].guests = guests.filter { $0.eventId == eventId }
        }
    }
    
    private func updateEventRSVPList(eventId: String) {
        if let index = events.firstIndex(where: { $0.id == eventId }) {
            events[index].rsvps = rsvps.filter { $0.eventId == eventId }
        }
    }
    
    private func generateQRCode() -> String {
        return "QR_\(UUID().uuidString.prefix(8))"
    }
    
    private func sendQRCodeToGuest(guest: Guest, qrCode: String) {
        // In a real app, this would integrate with WhatsApp API
        print("Sending QR code \(qrCode) to \(guest.name) at \(guest.phoneNumber)")
    }
    
    private func clearEventForm() {
        newEventName = ""
        newEventDate = Date()
        newEventTime = ""
        newEventVenue = ""
        newEventDescription = ""
        selectedCoverImage = nil
    }
    
    private func clearGuestForm() {
        newGuestName = ""
        newGuestPhone = ""
        newGuestEmail = ""
    }
}