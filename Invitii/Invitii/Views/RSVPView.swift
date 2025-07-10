import SwiftUI

struct RSVPView: View {
    let eventId: String
    let guestId: String
    @EnvironmentObject var eventViewModel: EventViewModel
    @State private var selectedStatus: RSVPStatus = .pending
    @State private var message = ""
    @State private var isSubmitted = false
    @State private var event: Event?
    @State private var guest: Guest?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    if let event = event {
                        // Event Header
                        eventHeaderSection(event: event)
                        
                        if !isSubmitted {
                            // RSVP Form
                            rsvpFormSection
                        } else {
                            // Success Message
                            successSection
                        }
                    } else {
                        // Loading or Error
                        ProgressView("Loading invitation...")
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
            .background(
                LinearGradient(
                    colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .onAppear {
            loadEventData()
        }
    }
    
    private func eventHeaderSection(event: Event) -> some View {
        VStack(spacing: 20) {
            // Cover Image Placeholder
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.purple, Color.blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 200)
                .overlay(
                    VStack {
                        Image(systemName: "envelope.open.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                        
                        Text("You're Invited!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                )
            
            // Event Details
            VStack(spacing: 12) {
                Text(event.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        Text(event.date, style: .date)
                        Text("at \(event.time)")
                    }
                    .font(.subheadline)
                    
                    HStack {
                        Image(systemName: "location")
                            .foregroundColor(.blue)
                        Text(event.venue)
                    }
                    .font(.subheadline)
                }
                .foregroundColor(.secondary)
                
                if !event.description.isEmpty {
                    Text(event.description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private var rsvpFormSection: some View {
        VStack(spacing: 20) {
            Text("Will you be attending?")
                .font(.title2)
                .fontWeight(.semibold)
            
            // RSVP Options
            VStack(spacing: 12) {
                RSVPOptionButton(
                    title: "Yes, I'll be there!",
                    subtitle: "Looking forward to it",
                    status: .yes,
                    selectedStatus: $selectedStatus,
                    color: .green
                )
                
                RSVPOptionButton(
                    title: "Maybe",
                    subtitle: "I'll try my best to attend",
                    status: .maybe,
                    selectedStatus: $selectedStatus,
                    color: .orange
                )
                
                RSVPOptionButton(
                    title: "Sorry, can't make it",
                    subtitle: "Unable to attend",
                    status: .no,
                    selectedStatus: $selectedStatus,
                    color: .red
                )
            }
            
            // Message Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Add a message (optional)")
                    .font(.headline)
                
                TextField("Your message to the host...", text: $message, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
            }
            
            // Submit Button
            Button(action: submitRSVP) {
                HStack {
                    Image(systemName: "envelope.fill")
                    Text("Send RSVP")
                }
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    selectedStatus == .pending ? Color.gray : Color.blue
                )
                .cornerRadius(12)
            }
            .disabled(selectedStatus == .pending)
            .animation(.easeInOut, value: selectedStatus)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private var successSection: some View {
        VStack(spacing: 25) {
            // Success Icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            // Success Message
            VStack(spacing: 12) {
                Text("RSVP Submitted!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Thank you for your response. The host has been notified.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Status-specific messages
            if selectedStatus == .yes {
                VStack(spacing: 15) {
                    Text("🎉 Great! You're confirmed for the event.")
                        .font(.headline)
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                    
                    Text("You'll receive a QR code via WhatsApp for event entry.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    // QR Code Display (simulated)
                    QRCodeDisplayView()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private func loadEventData() {
        // In a real app, this would fetch from API
        event = eventViewModel.events.first { $0.id == eventId }
        guest = eventViewModel.guests.first { $0.id == guestId }
        
        // Mark invitation as opened
        if let guestIndex = eventViewModel.guests.firstIndex(where: { $0.id == guestId }) {
            eventViewModel.guests[guestIndex].hasOpened = true
        }
    }
    
    private func submitRSVP() {
        guard selectedStatus != .pending else { return }
        
        eventViewModel.processRSVP(
            guestId: guestId,
            eventId: eventId,
            status: selectedStatus,
            message: message.isEmpty ? nil : message
        )
        
        withAnimation(.spring()) {
            isSubmitted = true
        }
    }
}

struct RSVPOptionButton: View {
    let title: String
    let subtitle: String
    let status: RSVPStatus
    @Binding var selectedStatus: RSVPStatus
    let color: Color
    
    var isSelected: Bool {
        selectedStatus == status
    }
    
    var body: some View {
        Button(action: {
            selectedStatus = status
        }) {
            HStack(spacing: 15) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? color : .gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? color.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? color : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct QRCodeDisplayView: View {
    var body: some View {
        VStack(spacing: 12) {
            // Simulated QR Code
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black)
                .frame(width: 120, height: 120)
                .overlay(
                    VStack {
                        Text("QR")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("CODE")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                )
            
            Text("Your Entry Pass")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    RSVPView(eventId: "event123", guestId: "guest123")
        .environmentObject(EventViewModel())
}