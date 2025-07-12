# Invitii - Digital Invitation & RSVP Platform

A cross-platform mobile application built with Flutter for iOS and Android, targeting the GCC region with digital wedding and event invitations via WhatsApp delivery and QR-code entry management.

## 🌟 Features

### Core Functionality
- **📱 Cross-Platform**: Native experience on both iOS and Android
- **🎯 Digital Invitations**: Create and send beautiful digital invitations
- **📲 WhatsApp Integration**: Direct delivery via WhatsApp Cloud API
- **📊 Real-time Analytics**: Live RSVP tracking and analytics dashboard
- **🔍 QR Code Management**: Secure QR code generation and validation
- **👥 Guest Management**: Add guests manually or import via CSV
- **📈 Role-based Access**: Host, Door Staff, and Admin permissions

### MVP Features (Q3-25 Release)
- ✅ **Unlimited Events**: No limit on event creation
- ✅ **Media Upload**: Support for JPG/PNG/MP4 files (≤20MB)
- ✅ **CSV Import**: Bulk guest import functionality
- ✅ **WhatsApp Cloud API**: Professional message delivery
- ✅ **Web RSVP Page**: Yes/No/Maybe response options
- ✅ **Real-time Dashboard**: Live statistics and analytics
- ✅ **QR Scanner**: Door staff check-in functionality
- ✅ **Data Export**: CSV export for all event data
- ✅ **JWT Authentication**: Secure user authentication
- ✅ **5k+ Guest Capacity**: Enterprise-level scalability

## 🏗️ Architecture

### Technology Stack
- **Frontend**: Flutter 3.1+ (Dart)
- **State Management**: Riverpod
- **UI Framework**: Material Design 3 with custom theming
- **Local Storage**: Hive + SharedPreferences
- **HTTP Client**: Dio with Retrofit
- **Authentication**: JWT with auto-refresh
- **QR Codes**: qr_flutter + qr_code_scanner
- **Design**: Google Fonts (Poppins) + Purple branding

### Project Structure
```
lib/
├── main.dart                           # App entry point
├── core/                              # Core utilities and shared code
│   ├── constants/app_constants.dart   # App-wide constants
│   ├── theme/app_theme.dart          # Purple theme and styling
│   └── models/                       # Data models
│       ├── event.dart               # Event model with analytics
│       ├── guest.dart               # Guest model with validation
│       ├── rsvp.dart                # RSVP model with status
│       └── user.dart                # User model with roles
├── features/                         # Feature-based organization
│   ├── auth/                        # Authentication
│   │   ├── presentation/
│   │   │   ├── screens/login_screen.dart
│   │   │   ├── providers/auth_provider.dart
│   │   │   └── widgets/             # Custom form widgets
│   │   └── data/repositories/       # Auth API calls
│   ├── home/                        # Dashboard and navigation
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── main_navigation_screen.dart
│   │       │   └── dashboard_screen.dart
│   │       └── widgets/             # Dashboard cards
│   ├── events/                      # Event management
│   │   └── presentation/screens/    # Event CRUD operations
│   ├── qr_scanner/                  # QR code functionality
│   │   └── presentation/screens/qr_scanner_screen.dart
│   └── profile/                     # User profile management
└── services/                        # External integrations
    ├── api_service.dart            # REST API client
    ├── whatsapp_service.dart       # WhatsApp Cloud API
    └── qr_code_generator.dart      # Secure QR generation
```

## 🎨 Design System

### Purple Branding Theme
- **Primary**: #7B2CBF (Purple)
- **Secondary**: #4361EE (Blue)
- **Success**: #06D6A0 (Green)
- **Warning**: #FFD60A (Yellow)
- **Error**: #EF476F (Red)

### Typography
- **Font Family**: Poppins (Google Fonts)
- **Responsive Scaling**: 12px - 32px
- **Weight Variations**: Regular, Medium, SemiBold, Bold

### Components
- **Gradient Buttons**: Animated with press effects
- **Custom Text Fields**: Animated borders and validation
- **Dashboard Cards**: Real-time statistics with icons
- **Bottom Navigation**: Role-based tab filtering

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.1.0 or higher
- Dart SDK 3.0.0 or higher
- iOS 17.0+ / Android API 21+ (5.0)
- Xcode 15.0+ (for iOS development)
- Android Studio (for Android development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/invitii-flutter.git
   cd invitii-flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code (JSON serialization)**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Configure API endpoints**
   ```dart
   // lib/core/constants/app_constants.dart
   static const String baseUrl = 'https://your-api.invitii.com';
   static const String whatsappPhoneNumberId = 'YOUR_PHONE_NUMBER_ID';
   static const String whatsappAccessToken = 'YOUR_ACCESS_TOKEN';
   ```

5. **Run the application**
   ```bash
   # iOS
   flutter run -d ios
   
   # Android
   flutter run -d android
   ```

## 📱 Core Screens

### 1. Authentication
- **Login Screen**: Purple gradient design with animations
- **Register Screen**: Multi-step registration process
- **Forgot Password**: Email-based password recovery

### 2. Dashboard
- **Analytics Cards**: Total events, guests, RSVPs, response rates
- **Quick Actions**: Create event, scan QR, view reports
- **Recent Activity**: Latest events and RSVP responses
- **Role-based UI**: Different views for Host vs Door Staff

### 3. Event Management
- **Event Creation**: Form with media upload and guest management
- **Event List**: Filterable list with search and sorting
- **Event Details**: Full analytics with guest list and RSVP status
- **Guest Import**: CSV file upload with validation

### 4. QR Code System
- **QR Generation**: Secure codes with SHA256 signatures
- **QR Scanner**: Real-time validation with success/error states
- **Check-in Flow**: Guest verification and entry tracking
- **Offline Support**: Cached data for network-free scanning

### 5. Profile & Settings
- **User Profile**: Edit personal information and preferences
- **Security**: Change password and security settings
- **Export Data**: Download event data in CSV format
- **Support**: Help documentation and contact information

## 🔐 Security Features

### Authentication
- **JWT Tokens**: Secure authentication with auto-refresh
- **Role-based Access**: Host, Door Staff, Admin permissions
- **Session Management**: Automatic logout on token expiry

### QR Code Security
- **SHA256 Signatures**: Cryptographically secure QR codes
- **Expiration Validation**: Time-based code expiry
- **Single-use Enforcement**: Prevent duplicate entries
- **Tamper Detection**: Invalid QR code detection

### Data Protection
- **Input Validation**: Client and server-side validation
- **SQL Injection Prevention**: Parameterized queries
- **HTTPS Only**: Encrypted data transmission
- **Local Storage Encryption**: Secure local data storage

## 🌍 Localization & GCC Support

### Regional Features
- **Phone Number Validation**: GCC country codes (+965, +966, +971, etc.)
- **Arabic Language Support**: RTL text support (Future release)
- **Local Date Formats**: Regional date and time formatting
- **Currency Support**: KWD, SAR, AED formatting

### WhatsApp Integration
- **Template Messages**: Pre-approved WhatsApp templates
- **Media Support**: Image and video invitation sharing
- **Delivery Status**: Real-time delivery confirmations
- **Fallback Options**: SMS backup for non-WhatsApp users

## 📊 Analytics & Reporting

### Real-time Metrics
- **Response Rates**: Live RSVP tracking percentages
- **Guest Analytics**: Invitation open rates and engagement
- **Check-in Statistics**: Real-time event attendance
- **Performance Metrics**: <2s load time monitoring

### Export Options
- **CSV Export**: Complete guest lists with RSVP status
- **Analytics Reports**: Event performance summaries
- **Attendance Lists**: Check-in status for door staff
- **Historical Data**: Event comparison and trends

## 🔧 API Integration

### REST API Endpoints
```dart
// Authentication
POST /auth/login          # User login
POST /auth/register       # User registration
POST /auth/refresh        # Token refresh

// Events
GET /events              # List user events
POST /events             # Create new event
PUT /events/{id}         # Update event
DELETE /events/{id}      # Delete event

// Guests
GET /events/{id}/guests   # Get event guests
POST /events/{id}/guests  # Add guest
POST /events/{id}/import  # Bulk import CSV

// RSVPs
POST /rsvp               # Submit RSVP
GET /events/{id}/rsvps   # Get event RSVPs

// QR Codes
POST /qr/validate        # Validate QR code
POST /qr/use            # Mark QR as used
```

### WhatsApp Cloud API
- **Message Templates**: Pre-approved invitation templates
- **Media Messaging**: Image and video sharing
- **Status Webhooks**: Delivery and read confirmations
- **Rate Limiting**: Compliance with WhatsApp policies

## 🚀 Performance Optimization

### Loading Performance
- **<2s Load Times**: Optimized asset loading and caching
- **Image Compression**: Automatic image optimization
- **Lazy Loading**: On-demand content loading
- **State Persistence**: Maintain state across app launches

### Memory Management
- **Efficient State**: Riverpod provider optimization
- **Image Caching**: Smart image caching with cleanup
- **Background Processing**: Offload heavy operations
- **Memory Profiling**: Regular memory usage monitoring

## 🧪 Testing

### Test Coverage
```bash
# Run all tests
flutter test

# Generate coverage report
flutter test --coverage
```

### Test Structure
- **Unit Tests**: Model validation and business logic
- **Widget Tests**: UI component testing
- **Integration Tests**: End-to-end user flows
- **Golden Tests**: UI consistency verification

## 🚀 Deployment

### iOS Deployment
1. **Configure signing**: Set up development/distribution certificates
2. **Build IPA**: `flutter build ipa --release`
3. **Upload to App Store**: Via Xcode or Transporter
4. **TestFlight**: Beta testing with stakeholders

### Android Deployment
1. **Generate keystore**: Create signing key for release
2. **Build APK/AAB**: `flutter build apk --release`
3. **Google Play Console**: Upload and configure release
4. **Internal Testing**: Alpha/beta testing tracks

## 📈 Roadmap

### Q3-25 (MVP Launch)
- ✅ Complete core functionality
- ✅ Kuwait and Saudi Arabia pilot
- ✅ WhatsApp integration
- ✅ QR code system

### Q4-25 (UX Enhancement)
- 🔄 Advanced analytics dashboard
- 🔄 Stripe payment integration
- 🔄 Video invitation templates
- 🔄 Push notifications

### Q1-26 (Full Launch)
- 🔄 Multi-language support (Arabic)
- 🔄 Advanced customization options
- 🔄 Integration marketplace
- 🔄 Enterprise features

## 🤝 Contributing

### Development Setup
1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Code Standards
- **Dart Style**: Follow official Dart style guide
- **Documentation**: Document all public APIs
- **Testing**: Write tests for new features
- **Performance**: Profile memory and CPU usage

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 💬 Support

### Contact Information
- **Email**: tech@invitii.com
- **Website**: https://invitii.com
- **Documentation**: https://docs.invitii.com

### Community
- **GitHub Issues**: Bug reports and feature requests
- **Discord**: Developer community chat
- **Twitter**: @invitii_app for updates

---

**Built with ❤️ for the GCC region wedding and events industry**

*Invitii - Making every invitation memorable*