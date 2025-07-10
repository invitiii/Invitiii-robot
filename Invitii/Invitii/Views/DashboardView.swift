import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTimeRange = "This Month"
    
    let timeRanges = ["This Week", "This Month", "Last 3 Months", "This Year"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Stats Cards
                    statsCardsSection
                    
                    // Recent Events
                    recentEventsSection
                    
                    // Quick Actions
                    quickActionsSection
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Profile") {
                        // Profile action
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sign Out") {
                        authViewModel.logout()
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Welcome back,")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text(authViewModel.currentUser?.name ?? "User")
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                // Time Range Picker
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(timeRanges, id: \.self) { range in
                        Text(range).tag(range)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .buttonStyle(BorderedButtonStyle())
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var statsCardsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 15) {
            StatCard(
                title: "Total Events",
                value: "\(eventViewModel.events.count)",
                icon: "calendar",
                color: .blue
            )
            
            StatCard(
                title: "Active Invites",
                value: "\(eventViewModel.totalInvitesSent)",
                icon: "envelope",
                color: .green
            )
            
            StatCard(
                title: "Total RSVPs",
                value: "\(eventViewModel.totalRSVPs)",
                icon: "checkmark.circle",
                color: .orange
            )
            
            StatCard(
                title: "Avg Response",
                value: formatResponseTime(eventViewModel.averageResponseTime),
                icon: "clock",
                color: .purple
            )
        }
    }
    
    private var recentEventsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Recent Events")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                NavigationLink("View All") {
                    EventListView()
                }
                .foregroundColor(.blue)
            }
            
            if eventViewModel.events.isEmpty {
                EmptyStateView(
                    icon: "calendar.badge.plus",
                    title: "No Events Yet",
                    description: "Create your first event to get started with Invitii"
                )
            } else {
                ForEach(Array(eventViewModel.events.prefix(3))) { event in
                    EventCardView(event: event)
                        .onTapGesture {
                            eventViewModel.selectEvent(event)
                        }
                }
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Quick Actions")
                .font(.title2)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                QuickActionButton(
                    title: "Create Event",
                    icon: "plus.circle.fill",
                    color: .blue
                ) {
                    // Navigate to event creation
                }
                
                QuickActionButton(
                    title: "Scan QR Code",
                    icon: "qrcode.viewfinder",
                    color: .green
                ) {
                    // Navigate to QR scanner
                }
                
                QuickActionButton(
                    title: "Import Guests",
                    icon: "person.3.fill",
                    color: .orange
                ) {
                    // Navigate to guest import
                }
                
                QuickActionButton(
                    title: "Export Data",
                    icon: "square.and.arrow.up",
                    color: .purple
                ) {
                    // Export functionality
                }
            }
        }
    }
    
    private func formatResponseTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval / 3600)
        if hours < 24 {
            return "\(hours)h"
        } else {
            let days = hours / 24
            return "\(days)d"
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct EventCardView: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(event.venue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(event.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(event.time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // RSVP Status Bar
            HStack(spacing: 8) {
                RSVPStatusBadge(count: event.confirmedCount, status: "Confirmed", color: .green)
                RSVPStatusBadge(count: event.declinedCount, status: "Declined", color: .red)
                RSVPStatusBadge(count: event.pendingCount, status: "Pending", color: .gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct RSVPStatusBadge: View {
    let count: Int
    let status: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.caption)
                .fontWeight(.semibold)
            
            Text(status)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .foregroundColor(color)
        .cornerRadius(6)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct EventListView: View {
    var body: some View {
        Text("Event List View")
            .navigationTitle("All Events")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DashboardView()
        .environmentObject(EventViewModel())
        .environmentObject(AuthViewModel())
}