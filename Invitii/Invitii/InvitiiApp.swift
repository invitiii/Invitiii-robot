import SwiftUI

@main
struct InvitiiApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var eventViewModel = EventViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(eventViewModel)
        }
    }
}