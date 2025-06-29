# CircleUp - Social Networking App

**"New city? Same roots. Let's meet."**

CircleUp is a Flutter mobile app that helps users connect socially based on shared college or company backgrounds. Think of it as Bumble BFF meets LinkedIn, where users can meet others with similar backgrounds to hang out, travel, chat, or make plans, especially when they're in new cities.

## Features

### MVP Features ✅
- **LinkedIn OAuth Authentication** - Sign in with LinkedIn to pull professional data
- **Profile Creation** - Complete profile setup with bio, interests, and personal info
- **Discovery Feed** - Swipeable card-based interface to discover new connections
- **College/Company Matching** - Find people from your alma mater or workplace
- **Beautiful UI** - Vibrant, friendly design with smooth animations
- **Firebase Backend** - Scalable backend with Firestore and Authentication

### Planned Features 🚧
- **Real-time Chat** - Message connections instantly
- **Connection Requests** - Send and receive connection requests
- **Location-based Discovery** - Find people nearby or in specific cities
- **Interest Matching** - Connect based on shared hobbies and interests
- **Event Creation** - Create and join local hangout plans
- **Advanced Filters** - Filter by city, college, company, or interests

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Auth, Firestore, Storage, Functions)
- **Authentication**: LinkedIn OAuth + Firebase Custom Auth
- **State Management**: Provider
- **Navigation**: GoRouter
- **UI**: Material Design 3 with custom theming
- **Animations**: flutter_animate

## Design Philosophy

### Visual Design
- **Friendly & Vibrant**: Rounded cards, playful animations, light gradients
- **College/Company Badges**: Visual indicators for shared backgrounds
- **"Meet real ones" vibe**: Not professional like LinkedIn, not dating like Tinder
- **Modern UI**: Clean, intuitive interface with smooth interactions

### User Experience
- **Simple Onboarding**: LinkedIn sign-in → Profile setup → Start discovering
- **Swipe Interface**: Familiar card-based discovery (swipe right to connect, left to pass)
- **Connection-focused**: Emphasis on shared backgrounds and common interests
- **Local & Remote**: Support for both local meetups and travel connections

## Getting Started

### Prerequisites
- Flutter SDK (3.10.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code
- Firebase project
- LinkedIn Developer Account (for OAuth)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/circleup.git
   cd circleup
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase for your project
   flutterfire configure
   ```

4. **LinkedIn OAuth Setup**
   - Create a LinkedIn app at [LinkedIn Developer Portal](https://developer.linkedin.com/)
   - Add your app credentials to `lib/services/auth_service.dart`
   - Configure redirect URLs in LinkedIn app settings

5. **Run the app**
   ```bash
   flutter run
   ```

### Firebase Configuration

Create a Firebase project and enable the following services:

1. **Authentication**
   - Enable Email/Password provider
   - Configure custom authentication for LinkedIn

2. **Firestore Database**
   - Create collections: `users`, `connections`, `chats`, `messages`
   - Set up security rules

3. **Storage**
   - Configure for profile images and media

4. **Functions** (Optional)
   - For advanced features like push notifications

### Project Structure

```
lib/
├── config/
│   ├── app_router.dart          # Navigation configuration
│   ├── app_theme.dart           # App theming and colors
│   └── firebase_options.dart    # Firebase configuration
├── models/
│   ├── user_model.dart          # User data model
│   └── connection_model.dart    # Connection data model
├── providers/
│   ├── auth_provider.dart       # Authentication state
│   ├── user_provider.dart       # User data management
│   ├── discovery_provider.dart  # Discovery logic
│   └── chat_provider.dart       # Chat functionality
├── screens/
│   ├── auth/                    # Authentication screens
│   ├── home/                    # Main app screens
│   ├── chat/                    # Chat screens
│   └── profile/                 # Profile screens
├── services/
│   ├── auth_service.dart        # Authentication logic
│   ├── user_service.dart        # User data operations
│   └── connection_service.dart  # Connection management
├── widgets/
│   └── user_card.dart           # Reusable UI components
└── main.dart                    # App entry point
```

## Key Components

### Authentication Flow
1. **Splash Screen** - App initialization and route determination
2. **Login Screen** - LinkedIn OAuth integration
3. **Profile Setup** - Complete user profile after first login
4. **Main Navigation** - Bottom tab navigation

### Discovery System
- **Card Stack**: Tinder-style swipeable cards
- **Smart Matching**: Prioritize college/company connections
- **Interest Filtering**: Match based on shared interests
- **Location Awareness**: Show nearby users

### Connection Logic
- **Like System**: Express interest in connecting
- **Mutual Matching**: Both users must like each other
- **Connection Requests**: Manage pending requests
- **Chat Activation**: Enable messaging after mutual connection

## Sample Taglines

- "New city? Same roots. Let's meet."
- "Where college & career connections turn into real-life plans."
- "Your people. Your vibe. Same college or company."
- "Swipe to chill, not date."

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, email support@circleup.app or join our Discord community.

---

**CircleUp** - Connecting people through shared experiences and backgrounds. 🎓🏢✨
