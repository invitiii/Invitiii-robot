import SwiftUI

struct QRScannerView: View {
    @EnvironmentObject var eventViewModel: EventViewModel
    @State private var scannedCode = ""
    @State private var showingResult = false
    @State private var scanResult: QRScanResult?
    @State private var selectedEvent: Event?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Event Selector
                eventSelectorSection
                
                if selectedEvent != nil {
                    // Scanner Section
                    scannerSection
                } else {
                    // Empty State
                    EmptyStateView(
                        icon: "qrcode.viewfinder",
                        title: "Select an Event",
                        description: "Choose an event to start scanning QR codes for check-in"
                    )
                }
            }
            .navigationTitle("QR Scanner")
        }
        .sheet(isPresented: $showingResult) {
            if let result = scanResult {
                ScanResultSheet(result: result, eventViewModel: eventViewModel)
            }
        }
    }
    
    private var eventSelectorSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Event:")
                    .font(.headline)
                
                Spacer()
                
                Picker("Event", selection: $selectedEvent) {
                    Text("Select Event").tag(nil as Event?)
                    ForEach(eventViewModel.events) { event in
                        Text(event.name).tag(event as Event?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            .padding()
            .background(Color(.systemGray6))
            
            if let event = selectedEvent {
                CheckInStatsView(event: event, eventViewModel: eventViewModel)
            }
        }
    }
    
    private var scannerSection: some View {
        VStack(spacing: 20) {
            // Scanner Camera View Placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black)
                .frame(height: 300)
                .overlay(
                    VStack(spacing: 20) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                        
                        Text("QR Code Scanner")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text("Camera access required")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                )
            
            // Manual Entry
            VStack(spacing: 12) {
                TextField("Or enter QR code manually", text: $scannedCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Validate Code") {
                    if !scannedCode.isEmpty {
                        handleQRCodeScan(scannedCode)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(scannedCode.isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(scannedCode.isEmpty)
            }
        }
        .padding()
    }
    
    private func handleQRCodeScan(_ qrCode: String) {
        let result = eventViewModel.validateQRCode(qrCode)
        scanResult = result
        showingResult = true
        
        if result.isValid && !result.isAlreadyUsed {
            eventViewModel.markQRCodeAsUsed(result.rsvpId)
        }
        
        scannedCode = ""
    }
}

struct CheckInStatsView: View {
    let event: Event
    let eventViewModel: EventViewModel
    
    var checkedInCount: Int {
        eventViewModel.rsvps.filter { $0.eventId == event.id && $0.qrCodeUsed }.count
    }
    
    var body: some View {
        HStack(spacing: 20) {
            StatItem(title: "Confirmed", value: event.confirmedCount, color: .green)
            StatItem(title: "Checked In", value: checkedInCount, color: .blue)
            StatItem(title: "Remaining", value: event.confirmedCount - checkedInCount, color: .orange)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct StatItem: View {
    let title: String
    let value: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ScanResultSheet: View {
    let result: QRScanResult
    let eventViewModel: EventViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Result Icon
                Image(systemName: result.isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(result.isValid ? .green : .red)
                
                // Result Details
                VStack(spacing: 15) {
                    Text(result.isValid ? "Valid Entry" : "Invalid QR Code")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(result.isValid ? .green : .red)
                    
                    if result.isValid {
                        VStack(spacing: 8) {
                            Text("Welcome, \(result.guestName)!")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Guest has been checked in successfully")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        VStack(spacing: 8) {
                            if result.isAlreadyUsed {
                                Text("QR Code Already Used")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                                
                                Text("This guest has already been checked in")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            } else {
                                Text(result.errorMessage ?? "Invalid QR Code")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                
                                Text("Please verify the QR code and try again")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .multilineTextAlignment(.center)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button("Continue Scanning") {
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Close") {
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                }
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    QRScannerView()
        .environmentObject(EventViewModel())
}