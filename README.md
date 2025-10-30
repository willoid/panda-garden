# 🐼 Panda in the Garden

A Flutter mobile application for managing garden visits with a unique panda-visitor system. The app allows a Panda (admin) to manage their garden status and approve visitor requests, while visitors can view the panda's status and request garden visits.

## 🌟 Features

### For Panda (Admin)
- **Status Management**: Update your current status (Not in Garden, Going to Garden, In Garden)
- **Visitor Requests**: Approve or deny visitor requests with push notifications
- **Visitor Management**: View and manage approved/pending visitors
- **Dashboard Overview**: See garden statistics at a glance
- **Real-time Updates**: Instant status updates visible to all visitors

### For Visitors
- **Registration**: Easy sign-up process (visitors only)
- **Panda Status Viewing**: Real-time view of panda's location status
- **Visit Requests**: Request garden visits with preferred date/time
- **Status Updates**: Update your own status once approved
- **Request History**: Track all your visit requests and their status

## 📱 Screenshots

### App Flow
1. **Splash Screen**: Animated panda logo with garden theme
2. **Login/Register**: Secure authentication with visitor registration
3. **Panda Dashboard**: Three tabs - Status, Requests, Visitors
4. **Visitor Dashboard**: Status view, request visits, view history

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- An Android/iOS device or emulator

### Installation

1. **Clone or extract the project**
   ```bash
   cd panda_garden
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Platform-specific Setup

#### Android
No additional setup required for basic functionality.

For push notifications on Android:
1. Add Firebase to your project
2. Configure FCM in `android/app/google-services.json`

#### iOS
For push notifications on iOS:
1. Enable Push Notifications in Xcode capabilities
2. Configure APNs certificates

## 🔑 Test Credentials

### Panda Account (Pre-existing Admin)
- **Email**: panda@garden.com
- **Password**: panda123

### Sample Visitor Account
- **Email**: alice@example.com
- **Password**: visitor123

### Register New Visitor
- Use the registration form on the login screen
- All new accounts are registered as visitors
- Requires panda approval to access full features

## 📂 Project Structure

```
panda_garden/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models
│   │   ├── user.dart            # User and status models
│   │   └── visitor_request.dart # Request model
│   ├── services/                 # Business logic
│   │   ├── auth_service.dart    # Authentication
│   │   ├── database_service.dart # Mock database
│   │   ├── garden_service.dart  # Garden state management
│   │   └── notification_service.dart # Push notifications
│   ├── screens/                  # UI screens
│   │   ├── splash_screen.dart   # Splash screen
│   │   ├── login_screen.dart    # Login/Register
│   │   ├── panda_dashboard.dart # Panda admin dashboard
│   │   └── visitor_dashboard.dart # Visitor dashboard
│   ├── widgets/                  # Reusable widgets
│   │   ├── status_selector.dart # Status selection widget
│   │   ├── visitor_card.dart    # Visitor display card
│   │   └── request_card.dart    # Request display card
│   └── theme/                    # App theming
│       └── app_theme.dart       # Colors and styles
└── pubspec.yaml                  # Dependencies

```

## 🎨 Customization

### Theme Colors
The app uses a panda/garden-inspired color scheme:
- **Primary**: Bamboo Green (#4CAF50)
- **Secondary**: Garden Green (#66BB6A)
- **Accent**: Orange (#FF9800)
- **Background**: Panda White (#FAFAFA)
- **Text**: Panda Black (#1A1A1A)

Modify colors in `lib/theme/app_theme.dart`

### Status Emojis
Current status emojis:
- 🏠 Not in Garden
- 🚶 Going to Garden
- 🌳 In Garden

Modify in `lib/models/user.dart` (GardenStatusExtension)

## 💾 Database

The app currently uses a mock in-memory database (`DatabaseService`) for demonstration. 

### To Connect Real Database:
1. Replace `DatabaseService` implementation with your backend API calls
2. Add appropriate HTTP client (dio, http package)
3. Implement proper authentication tokens
4. Add error handling and retry logic

### Firebase Integration Example:
```dart
// Add to pubspec.yaml:
// cloud_firestore: ^4.13.0
// firebase_auth: ^4.15.0

// Replace mock database with Firestore collections:
// - users collection
// - requests collection
// - Add real-time listeners for updates
```

## 🔔 Push Notifications

The app includes push notification setup using `flutter_local_notifications`. 

### To Enable Full Push Notifications:
1. Add Firebase Cloud Messaging (FCM)
2. Implement background message handling
3. Configure platform-specific notification channels
4. Add notification permissions handling

## 🧪 Testing

### Running Tests
```bash
flutter test
```

### Test Scenarios
1. **User Registration**: Create new visitor account
2. **Login Flow**: Test both panda and visitor login
3. **Status Updates**: Change panda/visitor status
4. **Request Flow**: Create, approve, deny requests
5. **Visitor Management**: Approve/remove visitors

## 📝 Known Limitations

1. **Mock Database**: Data resets on app restart
2. **Local Notifications Only**: No remote push notifications
3. **No Real Backend**: Using in-memory storage
4. **No Image Upload**: Using emojis instead of profile pictures
5. **No Chat Feature**: Direct garden visit requests only

## 🚧 Future Enhancements

- [ ] Real backend integration (Firebase/Supabase)
- [ ] Remote push notifications
- [ ] User profile pictures
- [ ] Garden schedule/calendar view
- [ ] Chat between panda and visitors
- [ ] Multiple pandas support
- [ ] Garden capacity limits
- [ ] Visit history analytics
- [ ] Weather integration
- [ ] Garden map/location feature

## 🐛 Troubleshooting

### Common Issues

1. **Build Errors**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Notification Permission Issues**
   - iOS: Check notification settings in device
   - Android: Ensure app has notification permission

3. **State Not Updating**
   - Pull to refresh on dashboard screens
   - Check Provider listeners are properly set

## 📄 License

This project is created for demonstration purposes.

## 🤝 Support

For issues or questions about this demo app, please refer to the Flutter documentation or create an issue in the project repository.

---

Made with 🐼 and Flutter
