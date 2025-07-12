import SwiftUI
import PhotosUI

struct EventCreationView: View {
    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedMediaItem: PhotosPickerItem?
    @State private var selectedMediaType: MediaType = .image
    @State private var showingImagePicker = false
    @State private var showingSuccessAlert = false
    
    enum MediaType: String, CaseIterable {
        case image = "Image"
        case video = "Video"
        
        var icon: String {
            switch self {
            case .image: return "photo"
            case .video: return "video"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Event Details") {
                    TextField("Event Name", text: $eventViewModel.newEventName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    DatePicker("Date", selection: $eventViewModel.newEventDate, displayedComponents: .date)
                    
                    TextField("Time (e.g., 18:00)", text: $eventViewModel.newEventTime)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Venue", text: $eventViewModel.newEventVenue)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Description (Optional)", text: $eventViewModel.newEventDescription, axis: .vertical)
                        .lineLimit(3...6)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section("Cover Media") {
                    VStack(spacing: 15) {
                        // Media Type Selector
                        Picker("Media Type", selection: $selectedMediaType) {
                            ForEach(MediaType.allCases, id: \.self) { type in
                                Label(type.rawValue, systemImage: type.icon)
                                    .tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        // Media Upload Area
                        mediaUploadSection
                        
                        Text("Max file size: 20MB")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Quick Start") {
                    VStack(spacing: 12) {
                        Button(action: {
                            createEventAndNavigateToGuests()
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Create Event & Add Guests")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            createEvent()
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle")
                                Text("Create Event Only")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("Create Event")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save Draft") {
                        // Save as draft functionality
                    }
                    .foregroundColor(.blue)
                }
            }
            .alert("Event Created Successfully!", isPresented: $showingSuccessAlert) {
                Button("OK") { }
            } message: {
                Text("Your event has been created. You can now add guests and send invitations.")
            }
            .onChange(of: selectedMediaItem) { _, newItem in
                Task {
                    if let newItem = newItem {
                        await loadSelectedMedia(from: newItem)
                    }
                }
            }
        }
    }
    
    private var mediaUploadSection: some View {
        VStack(spacing: 12) {
            if let selectedImage = eventViewModel.selectedCoverImage {
                // Show selected image
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(10)
                    .overlay(
                        Button(action: {
                            eventViewModel.selectedCoverImage = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        .padding(8),
                        alignment: .topTrailing
                    )
            } else {
                // Upload button
                PhotosPicker(
                    selection: $selectedMediaItem,
                    matching: selectedMediaType == .image ? .images : .videos
                ) {
                    VStack(spacing: 12) {
                        Image(systemName: selectedMediaType == .image ? "photo.badge.plus" : "video.badge.plus")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        
                        Text("Select \(selectedMediaType.rawValue)")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text("Choose from your photo library")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, dash: [5]))
                    )
                }
            }
        }
    }
    
    private func createEvent() {
        guard validateForm() else { return }
        
        if let hostId = authViewModel.currentUser?.id {
            eventViewModel.createEvent(hostId: hostId)
            showingSuccessAlert = true
        }
    }
    
    private func createEventAndNavigateToGuests() {
        guard validateForm() else { return }
        
        if let hostId = authViewModel.currentUser?.id {
            eventViewModel.createEvent(hostId: hostId)
            // In a real app, this would navigate to guest management
            showingSuccessAlert = true
        }
    }
    
    private func validateForm() -> Bool {
        return !eventViewModel.newEventName.isEmpty &&
               !eventViewModel.newEventVenue.isEmpty &&
               !eventViewModel.newEventTime.isEmpty
    }
    
    private func loadSelectedMedia(from item: PhotosPickerItem) async {
        if let data = try? await item.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            await MainActor.run {
                eventViewModel.selectedCoverImage = image
            }
        }
    }
}

// MARK: - Supporting Views

struct MediaPreviewView: View {
    let image: UIImage?
    let onRemove: () -> Void
    
    var body: some View {
        if let image = image {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(10)
                
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                .padding(8)
            }
        }
    }
}

struct FormValidationView: View {
    let isValid: Bool
    let message: String
    
    var body: some View {
        if !isValid {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                
                Text(message)
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            .padding(.top, 5)
        }
    }
}

#Preview {
    EventCreationView()
        .environmentObject(EventViewModel())
        .environmentObject(AuthViewModel())
}