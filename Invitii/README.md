# Invitii - Digital Invitation & RSVP Platform (iOS App)

![Invitii Logo](https://img.shields.io/badge/Invitii-Digital%20Invitations-purple)
![iOS](https://img.shields.io/badge/iOS-17.0+-blue)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Latest-green)
![License](https://img.shields.io/badge/License-MIT-orange)

## Overview

Invitii is a comprehensive iOS application that enables hosts to send digital invitations via WhatsApp, collect real-time RSVPs, and automatically issue unique entry QR codes to confirmed guests. This app is specifically designed for weddings and events in the GCC region.

## Features

### 🎉 Core Features (MVP)
- **Event Management**: Create, edit, and manage unlimited events
- **Digital Invitations**: Upload JPG/PNG images or MP4 videos (≤ 20 MB)
- **Guest Management**: Import guests via CSV or add manually
- **WhatsApp Integration**: Send personalized invitations via WhatsApp Cloud API
- **Real-time RSVP**: Web-based RSVP with Yes/No/Maybe options
- **QR Code Generation**: Unique QR codes for confirmed guests
- **Check-in Scanner**: QR code scanner for event entry
- **Dashboard Analytics**: Real-time RSVP statistics and insights
- **Data Export**: CSV export of attendance data

### 📱 Technical Features
- **Modern UI**: Built with SwiftUI for iOS 17+
- **MVVM Architecture**: Clean separation of concerns
- **Real-time Updates**: Live dashboard updates
- **Offline Support**: Cached guest lists for check-in
- **Security**: JWT authentication and QR code signatures
- **Performance**: Optimized for <2s load times

## Architecture

### Project Structure
```
Invitii/
├── Invitii/
│   ├── InvitiiApp.swift           # App entry point
│   ├── ContentView.swift          # Main navigation
│   ├── Models/                    # Data models
│   │   ├── Event.swift
│   │   ├── Guest.swift
│   │   ├── RSVP.swift
│   │   └── User.swift
│   ├── Views/                     # SwiftUI views
│   │   ├── DashboardView.swift
│   │   ├── EventCreationView.swift
│   │   ├── GuestListView.swift
│   │   ├── QRScannerView.swift
│   │   └── RSVPView.swift
│   ├── ViewModels/               # Business logic
│   │   ├── AuthViewModel.swift
│   │   └── EventViewModel.swift
│   ├── Services/                 # External integrations
│   │   ├── APIService.swift
│   │   ├── WhatsAppService.swift
│   │   └── QRCodeGenerator.swift
│   └── Assets.xcassets/          # App resources
└── README.md
```

### Data Models

#### Event
- Comprehensive event information
- RSVP statistics computation
- Guest and RSVP relationship management

#### Guest
- Contact information storage
- Phone number validation and formatting
- RSVP link generation

#### RSVP
- Response status tracking
- QR code association
- Guest information denormalization

#### User
- Authentication and role management
- Subscription tier handling
- Event creation limits

## Key Components

### 🏠 Dashboard
- Event overview and statistics
- Quick actions for common tasks
- Time-range filtered analytics
- Real-time RSVP monitoring

### 📅 Event Creation
- Intuitive form-based creation
- Media upload (images/videos)
- Date and venue management
- Description and customization

### 👥 Guest Management
- Manual guest addition
- CSV import functionality
- RSVP status tracking
- Search and filtering

### 📱 RSVP Interface
- Beautiful invitation display
- Simple Yes/No/Maybe responses
- Optional message inclusion
- QR code delivery for confirmed guests

### 🔍 QR Scanner
- Real-time QR code scanning
- Manual code entry option
- Validation and security checks
- Check-in statistics

## Services Integration

### WhatsApp Cloud API
- Template-based messaging
- Personalized invitation delivery
- QR code distribution
- RSVP confirmations

### QR Code System
- Secure code generation with signatures
- Base64 encoded data structure
- Expiration and validation logic
- Styled QR codes with branding

### API Service
- RESTful backend communication
- JWT authentication
- File upload handling
- Error management

## User Flows

### 1. Host Flow
```
Login → Create Event → Add Guests → Send Invitations → Monitor RSVPs → Check-in Guests
```

### 2. Guest Flow
```
Receive WhatsApp → Open Invitation → Respond (Yes/No/Maybe) → Receive QR Code (if Yes)
```

### 3. Door Staff Flow
```
Select Event → Scan QR Codes → Validate Entry → Track Check-ins
```

## Requirements Implementation

### Functional Requirements (PRD Compliance)
- ✅ F-1: Unlimited events support
- ✅ F-2: Media upload (JPG/PNG/MP4 ≤ 20MB)
- ✅ F-3: WhatsApp Cloud API integration
- ✅ F-4: Comprehensive guest data storage
- ✅ F-5: Single-use QR code generation
- ✅ F-6: Real-time dashboard updates
- ✅ F-7: Role-based access (Host/Door Staff)
- ✅ F-8: CSV/PDF export functionality

### Non-Functional Requirements
- **Performance**: SwiftUI optimizations for <2s load times
- **Security**: JWT authentication, QR code signatures
- **Scalability**: Designed for 5k+ guests per event
- **Accessibility**: VoiceOver support, Dynamic Type
- **Compliance**: WCAG 2.1 AA guidelines

## Installation & Setup

### Prerequisites
- Xcode 15.0+
- iOS 17.0+ deployment target
- Apple Developer Account (for device testing)

### Configuration

1. **WhatsApp Cloud API Setup**
   ```swift
   // Update WhatsAppService.swift
   private let phoneNumberId = "YOUR_PHONE_NUMBER_ID"
   private let accessToken = "YOUR_ACCESS_TOKEN"
   ```

2. **Backend API Configuration**
   ```swift
   // Update APIService.swift
   private let baseURL = "https://your-api-domain.com"
   ```

3. **Build and Run**
   ```bash
   # Open in Xcode
   open Invitii.xcodeproj
   
   # Build and run on simulator or device
   ⌘ + R
   ```

## API Integration

### Authentication Endpoints
```
POST /auth/login
POST /auth/register
```

### Event Management
```
GET    /events
POST   /events
PUT    /events/{id}
DELETE /events/{id}
```

### Guest & RSVP Management
```
GET    /events/{id}/guests
POST   /guests
DELETE /guests/{id}
GET    /events/{id}/rsvps
POST   /rsvp
```

### QR Code Operations
```
POST /qr/validate
POST /qr/use
```

## Security Features

### Authentication
- JWT token-based authentication
- Secure token storage in Keychain
- Automatic token refresh

### QR Code Security
- SHA256 signature validation
- Event-specific code generation
- Expiration date enforcement
- Single-use enforcement

### Data Protection
- HTTPS-only communication
- Input validation and sanitization
- Secure phone number formatting

## Testing Strategy

### Unit Tests
- Model validation
- ViewModel business logic
- Service layer functionality

### Integration Tests
- API communication
- WhatsApp message formatting
- QR code generation/validation

### UI Tests
- Navigation flows
- Form validation
- Error handling

## Performance Optimizations

### SwiftUI Best Practices
- Lazy loading for large lists
- Image caching and compression
- Efficient state management

### Network Optimizations
- Request batching
- Background queue processing
- Offline data caching

### Memory Management
- Weak references in closures
- Image memory management
- Large dataset pagination

## Deployment

### App Store Preparation
1. Configure app icons and launch screens
2. Update Info.plist with required permissions
3. Set up App Store Connect metadata
4. Submit for App Store review

### Enterprise Distribution
1. Configure enterprise certificates
2. Set up MDM integration
3. Prepare deployment documentation

## Future Enhancements

### Phase 2 Features (Q4 2025)
- Video invitation optimization
- Advanced analytics
- Push notifications
- Offline mode improvements

### Payment Integration (Stripe)
- Subscription management
- Per-event pricing
- Premium features unlock

### Regional Expansion
- Multi-language support
- Local payment methods
- Regional compliance

## Contributing

### Development Guidelines
1. Follow SwiftUI best practices
2. Maintain MVVM architecture
3. Write comprehensive tests
4. Document public APIs

### Code Style
- SwiftLint configuration
- Consistent naming conventions
- Proper error handling
- Accessibility considerations

## Support

### Technical Support
- Email: tech@invitii.com
- Documentation: docs.invitii.com
- GitHub Issues: github.com/invitii/ios-app

### Business Inquiries
- Email: business@invitii.com
- Website: invitii.com

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- SwiftUI community for inspiration
- WhatsApp Cloud API documentation
- GCC event planning industry insights

---

**Invitii Team**  
*Revolutionizing event management in the GCC* 🎉