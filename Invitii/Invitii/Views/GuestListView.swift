import SwiftUI

struct GuestListView: View {
    @EnvironmentObject var eventViewModel: EventViewModel
    @State private var showingAddGuestSheet = false
    @State private var showingImportSheet = false
    @State private var selectedEvent: Event?
    @State private var searchText = ""
    
    var filteredGuests: [Guest] {
        if searchText.isEmpty {
            return eventViewModel.guests
        } else {
            return eventViewModel.guests.filter { guest in
                guest.name.localizedCaseInsensitiveContains(searchText) ||
                guest.phoneNumber.contains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if eventViewModel.events.isEmpty {
                    EmptyStateView(
                        icon: "person.3.fill",
                        title: "No Events Yet",
                        description: "Create an event first to manage guests"
                    )
                } else {
                    VStack(spacing: 0) {
                        // Event Selector
                        eventSelectorSection
                        
                        // Guest List
                        if filteredGuests.isEmpty && selectedEvent != nil {
                            EmptyStateView(
                                icon: "person.badge.plus",
                                title: "No Guests Added",
                                description: "Add guests to start sending invitations"
                            )
                        } else {
                            List {
                                ForEach(filteredGuests) { guest in
                                    GuestRowView(guest: guest, eventViewModel: eventViewModel)
                                }
                                .onDelete(perform: deleteGuests)
                            }
                            .searchable(text: $searchText, prompt: "Search guests...")
                        }
                    }
                }
            }
            .navigationTitle("Guests")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingAddGuestSheet = true }) {
                            Label("Add Guest", systemImage: "person.badge.plus")
                        }
                        
                        Button(action: { showingImportSheet = true }) {
                            Label("Import from CSV", systemImage: "square.and.arrow.down")
                        }
                        
                        if let event = selectedEvent {
                            Button(action: { sendInvitations(for: event) }) {
                                Label("Send Invitations", systemImage: "envelope.fill")
                            }
                            
                            Button(action: { exportGuestList(for: event) }) {
                                Label("Export List", systemImage: "square.and.arrow.up")
                            }
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddGuestSheet) {
                AddGuestSheet(eventId: selectedEvent?.id ?? "")
            }
            .sheet(isPresented: $showingImportSheet) {
                ImportGuestsSheet(eventId: selectedEvent?.id ?? "")
            }
        }
    }
    
    private var eventSelectorSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Select Event:")
                    .font(.headline)
                
                Spacer()
                
                Picker("Event", selection: $selectedEvent) {
                    Text("Choose Event").tag(nil as Event?)
                    ForEach(eventViewModel.events) { event in
                        Text(event.name).tag(event as Event?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            .padding()
            .background(Color(.systemGray6))
            
            if let event = selectedEvent {
                RSVPSummaryView(event: event)
            }
        }
        .onChange(of: selectedEvent) { _, newEvent in
            if let event = newEvent {
                eventViewModel.selectEvent(event)
            }
        }
    }
    
    private func deleteGuests(at offsets: IndexSet) {
        for index in offsets {
            let guest = filteredGuests[index]
            eventViewModel.removeGuest(guest)
        }
    }
    
    private func sendInvitations(for event: Event) {
        eventViewModel.sendInvitations(for: event)
    }
    
    private func exportGuestList(for event: Event) {
        let csvContent = eventViewModel.exportGuestListToCSV(for: event)
        // In a real app, this would show share sheet
        print("CSV Export:\n\(csvContent)")
    }
}

struct GuestRowView: View {
    let guest: Guest
    let eventViewModel: EventViewModel
    
    var rsvp: RSVP? {
        eventViewModel.rsvps.first { $0.guestId == guest.id }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(guest.name)
                        .font(.headline)
                    
                    Text(guest.phoneNumber)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let email = guest.email {
                        Text(email)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    RSVPStatusBadge(
                        status: rsvp?.status ?? .pending,
                        showsQR: rsvp?.qrCode != nil
                    )
                    
                    if guest.hasOpened {
                        HStack {
                            Image(systemName: "envelope.open.fill")
                                .foregroundColor(.green)
                            Text("Opened")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    } else if guest.invitationSentAt != nil {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.blue)
                            Text("Sent")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            
            if let message = rsvp?.message, !message.isEmpty {
                Text("\"\(message)\"")
                    .font(.caption)
                    .italic()
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }
}

struct RSVPStatusBadge: View {
    let status: RSVPStatus
    let showsQR: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Text(status.displayName)
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(backgroundColor)
                .foregroundColor(textColor)
                .cornerRadius(12)
            
            if showsQR {
                Image(systemName: "qrcode")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
    }
    
    private var backgroundColor: Color {
        switch status {
        case .yes: return .green.opacity(0.2)
        case .no: return .red.opacity(0.2)
        case .maybe: return .orange.opacity(0.2)
        case .pending: return .gray.opacity(0.2)
        }
    }
    
    private var textColor: Color {
        switch status {
        case .yes: return .green
        case .no: return .red
        case .maybe: return .orange
        case .pending: return .gray
        }
    }
}

struct RSVPSummaryView: View {
    let event: Event
    
    var body: some View {
        HStack(spacing: 20) {
            SummaryItem(title: "Total", count: event.totalGuests, color: .blue)
            SummaryItem(title: "Confirmed", count: event.confirmedCount, color: .green)
            SummaryItem(title: "Declined", count: event.declinedCount, color: .red)
            SummaryItem(title: "Pending", count: event.pendingCount, color: .gray)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct SummaryItem: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct AddGuestSheet: View {
    @EnvironmentObject var eventViewModel: EventViewModel
    @Environment(\.dismiss) private var dismiss
    let eventId: String
    
    var body: some View {
        NavigationView {
            Form {
                Section("Guest Information") {
                    TextField("Full Name", text: $eventViewModel.newGuestName)
                    TextField("Phone Number", text: $eventViewModel.newGuestPhone)
                        .keyboardType(.phonePad)
                    TextField("Email (Optional)", text: $eventViewModel.newGuestEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("Add Guest")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        eventViewModel.addGuest(to: eventId)
                        dismiss()
                    }
                    .disabled(eventViewModel.newGuestName.isEmpty || eventViewModel.newGuestPhone.isEmpty)
                }
            }
        }
    }
}

struct ImportGuestsSheet: View {
    @EnvironmentObject var eventViewModel: EventViewModel
    @Environment(\.dismiss) private var dismiss
    let eventId: String
    @State private var csvText = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Import Guests from CSV")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Format: Name, Phone, Email (one guest per line)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("Paste CSV data here...", text: $csvText, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 200)
                
                Button("Import Guests") {
                    eventViewModel.importGuestsFromCSV(csvText, to: eventId)
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(csvText.isEmpty)
                
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    GuestListView()
        .environmentObject(EventViewModel())
}