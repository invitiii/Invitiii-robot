class AppConstants {
  static const String appName = 'Invitii';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Digital Invitations & RSVP Platform';
  
  // API Endpoints
  static const String baseUrl = 'https://api.invitii.com';
  static const String whatsappBaseUrl = 'https://graph.facebook.com/v18.0';
  
  // WhatsApp Configuration
  static const String whatsappPhoneNumberId = 'YOUR_PHONE_NUMBER_ID';
  static const String whatsappAccessToken = 'YOUR_ACCESS_TOKEN';
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String settingsKey = 'app_settings';
  
  // File Upload Limits
  static const int maxImageSizeBytes = 20 * 1024 * 1024; // 20MB
  static const int maxVideoSizeBytes = 20 * 1024 * 1024; // 20MB
  static const List<String> supportedImageTypes = ['jpg', 'jpeg', 'png'];
  static const List<String> supportedVideoTypes = ['mp4', 'mov'];
  
  // Event Limits
  static const int maxGuestsPerEvent = 5000;
  static const int freeEventLimit = 5;
  
  // QR Code Configuration
  static const String qrCodeSecret = 'INVITII_SECRET_KEY';
  static const int qrCodeSize = 250;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // Phone Number Formatting
  static const String defaultCountryCode = '+965'; // Kuwait
  static const List<String> gccCountryCodes = [
    '+965', // Kuwait
    '+966', // Saudi Arabia
    '+971', // UAE
    '+973', // Bahrain
    '+974', // Qatar
    '+968', // Oman
  ];
  
  // Error Messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'No internet connection. Please check your network.';
  static const String serverErrorMessage = 'Server error. Please try again later.';
  static const String invalidCredentialsMessage = 'Invalid email or password.';
  static const String emailRequiredMessage = 'Email is required.';
  static const String passwordRequiredMessage = 'Password is required.';
  static const String nameRequiredMessage = 'Name is required.';
  static const String phoneRequiredMessage = 'Phone number is required.';
  static const String eventNameRequiredMessage = 'Event name is required.';
  static const String venueRequiredMessage = 'Venue is required.';
  static const String timeRequiredMessage = 'Time is required.';
  
  // Success Messages
  static const String eventCreatedMessage = 'Event created successfully!';
  static const String invitationsSentMessage = 'Invitations sent successfully!';
  static const String rsvpSubmittedMessage = 'RSVP submitted successfully!';
  static const String guestAddedMessage = 'Guest added successfully!';
  static const String guestsImportedMessage = 'Guests imported successfully!';
  
  // CSV Headers
  static const List<String> csvHeaders = ['Name', 'Phone', 'Email', 'RSVP Status', 'Response Time'];
  
  // Date Formats
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayTimeFormat = 'HH:mm';
  static const String fullDateTimeFormat = 'MMM dd, yyyy HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';
  
  // URLs
  static const String privacyPolicyUrl = 'https://invitii.com/privacy';
  static const String termsOfServiceUrl = 'https://invitii.com/terms';
  static const String supportUrl = 'https://invitii.com/support';
  static const String websiteUrl = 'https://invitii.com';
  
  // Support Contact
  static const String supportEmail = 'support@invitii.com';
  static const String techSupportEmail = 'tech@invitii.com';
  static const String businessEmail = 'business@invitii.com';
  
  // Social Media
  static const String twitterHandle = '@invitii_app';
  static const String instagramHandle = '@invitii_official';
  
  // Feature Flags (for future use)
  static const bool enableVideoInvitations = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
}