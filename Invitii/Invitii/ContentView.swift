import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var eventViewModel: EventViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                TabView(selection: $selectedTab) {
                    DashboardView()
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Dashboard")
                        }
                        .tag(0)
                    
                    EventCreationView()
                        .tabItem {
                            Image(systemName: "plus.circle.fill")
                            Text("Create Event")
                        }
                        .tag(1)
                    
                    GuestListView()
                        .tabItem {
                            Image(systemName: "person.3.fill")
                            Text("Guests")
                        }
                        .tag(2)
                    
                    QRScannerView()
                        .tabItem {
                            Image(systemName: "qrcode.viewfinder")
                            Text("Scanner")
                        }
                        .tag(3)
                }
                .accentColor(.purple)
            } else {
                LoginView()
            }
        }
    }
}

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isRegisterMode = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Logo and Title
                VStack(spacing: 20) {
                    Image(systemName: "envelope.open.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.purple)
                    
                    Text("Invitii")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    
                    Text("Digital Invitations & RSVP Platform")
                        .font(.subtitle)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 50)
                
                // Login Form
                VStack(spacing: 20) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        if isRegisterMode {
                            authViewModel.register(email: email, password: password)
                        } else {
                            authViewModel.login(email: email, password: password)
                        }
                    }) {
                        Text(isRegisterMode ? "Sign Up" : "Sign In")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        isRegisterMode.toggle()
                    }) {
                        Text(isRegisterMode ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .foregroundColor(.purple)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(EventViewModel())
}