# Global Care Medical Center

## Project Overview

Global Care Medical Center is a comprehensive Flutter-based mobile application designed to optimize healthcare services for patients. The app provides an intuitive interface for booking medical appointments, providing feedback, managing user accounts, and accessing a personalized dashboard with healthcare insights. Built with a focus on user experience, accessibility, and responsive design, it supports both mobile and tablet devices, ensuring smooth and uninterrupted interaction across different screen sizes.

The application leverages modern Flutter packages and state management techniques to deliver a high-performance and maintainable codebase. It includes features such as user authentication, appointment scheduling, feedback submission, and data visualization through charts. The app is styled with a clean, professional design using the Poppins font and a cohesive indigo-themed color scheme.

## Features

### Core Features
- **User Authentication**: Secure login and sign-up functionality using `shared_preferences` for persistent storage. Users can register with a username, email, and password, and log in to access personalized features.
- **Appointment Booking**: Users can schedule appointments by selecting a department, doctor, appointment type, and providing a reason for the visit. A confirmation receipt is generated with details like appointment ID, date, and time.
- **Feedback System**: Authenticated users can submit feedback with a satisfaction rating (1-5 stars) and comments, which are stored locally and displayed in the dashboard.
- **Dashboard**: A personalized dashboard displaying user profile information, appointment history, feedback history, and data visualizations (charts for appointments by department, patient satisfaction, and appointment status).
- **Responsive Design**: The app adapts to different screen sizes (mobile and tablet) using `LayoutBuilder` for a consistent user experience.
- **Text Size Customization**: Users can adjust text size for better accessibility using a floating action button with increase, decrease, and reset options.
- **Navigation**: A tab-based navigation system with Home, Appointments, Feedback, and Dashboard sections, accessible via a responsive app bar or drawer (on mobile).

### Additional Features
- **Hero Section**: A visually appealing landing page with a background image, gradient overlay, and key statistics (e.g., number of doctors, departments, and patients).
- **Mission & Vision**: Displays the medical center's mission and vision statements in a dedicated section.
- **Services Section**: Highlights available medical services.
- **Contact Section**: Provides contact details (address, phone, email) with clickable links to initiate calls or emails using the `url_launcher` package.
- **PDF Generation**: Supports generating appointment receipts as PDF documents using the `pdf` and `printing` packages (though not fully implemented in the provided code).
- **Data Visualization**: Uses the `fl_chart` package to display bar charts for appointments by department, patient satisfaction trends, and appointment status.

## Technology Stack

- **Framework**: Flutter (Dart)
- **Local Storage**: `shared_preferences` for storing user data, appointments, and feedback
- **UI Components**: Material Design with custom theming
- **Fonts**: Google Fonts (`google_fonts` package, Poppins font family)
- **Data Formatting**: `intl` package for date formatting
- **Charts**: `fl_chart` for bar chart visualizations
- **External Links**: `url_launcher` for phone and email interactions
- **PDF Generation**: `pdf` and `printing` packages
- **Dependencies**:
  - `flutter`: SDK for building the app
  - `cupertino_icons`: iOS-style icons
  - `provider`: State management
  - `url_launcher`: Launch phone calls and emails
  - `intl`: Date and time formatting
  - `shared_preferences`: Local storage
  - `google_fonts`: Custom fonts
  - `fl_chart`: Chart visualizations
  - `pdf` and `printing`: PDF generation and printing

- **Development Dependencies**:
  - `flutter_test`: For unit and widget testing
  - `flutter_lints`: For code linting and best practices

## Project Structure

The project follows a modular structure to ensure maintainability and scalability. Below is an overview of the key components in `main.dart`:

- **GlobalCareApp**: The root widget that sets up the app's theme, routes, and text size provider using `MultiProvider`.
- **MainPage**: The main scaffold with a tab-based navigation system (Home, Appointments, Feedback, Dashboard) using `DefaultTabController`.
- **AuthService**: Manages user authentication (login, sign-up, logout) with local storage.
- **AppointmentService**: Handles appointment data storage and retrieval.
- **FeedbackService**: Manages feedback submission and retrieval.
- **TextSizeProvider**: Controls text scaling for accessibility.
- **Pages**:
  - `HomePage`: Displays the hero section, mission/vision, services, contact, and footer.
  - `AppointmentPage`: Allows users to book appointments.
  - `FeedbackPage`: Provides a form for submitting feedback (requires authentication).
  - `DashboardPage`: Shows user profile, appointment history, feedback history, and charts.
  - `AppointmentReceiptPage`: Displays appointment confirmation details.
- **Widgets**:
  - `HeroSection`, `MissionVisionSection`, `ServicesSection`, `ContactSection`, `FooterSection`: Reusable UI components for the home page.
  - `SectionHeader`, `FooterLink`, `ContactItem`, `StatItem`, `AppointmentHistory`: Modular widgets for consistent UI elements.
  - `AuthDialog`: A dialog for login and sign-up forms.

### File Structure
- `lib/main.dart`: Main application code containing all widgets and services.
- `pubspec.yaml`: Project configuration, dependencies, and assets.
- `assets/`: Contains Poppins font files (`Poppins-Regular.ttf`, `Poppins-Medium.ttf`, `Poppins-SemiBold.ttf`, `Poppins-Bold.ttf`).

## Setup and Installation

### Prerequisites
- Flutter SDK (version 3.8.1 or higher)
- Dart SDK
- A code editor (e.g., VS Code, Android Studio)
- An emulator or physical device for testing

### Installation Steps
1. **Clone the Repository**:
   ```bash
   git clone <repository-url>
   cd global_care
   ```

2. **Install Dependencies**:
   Run the following command to install all required packages:
   ```bash
   flutter pub get
   ```

3. **Add Assets**:
   Ensure the Poppins font files are placed in the `assets/` directory as specified in `pubspec.yaml`.

4. **Run the App**:
   Start the app on an emulator or device:
   ```bash
   flutter run
   ```

5. **Build for Production**:
   To create a release build:
   ```bash
   flutter build apk --release
   ```

### Configuration
- **Fonts**: The app uses the Poppins font, loaded via the `google_fonts` package and custom font files in the `assets/` directory.
- **Firebase**: The `firebase_core` package is included but not fully utilized. To enable Firebase features (e.g., cloud storage or authentication), configure Firebase in your project:
  - Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
  - Add your app to the Firebase project and download the `google-services.json` file.
  - Place the file in the `android/app/` directory and update `build.gradle` files as per Firebase instructions.
- **Assets**: Ensure the font files listed in `pubspec.yaml` are correctly placed in the `assets/` directory.

## Usage

1. **Launch the App**:
   - The app opens to the Home page with a hero section showcasing the medical center's mission and key statistics.
   - Use the navigation bar (desktop) or drawer (mobile) to switch between Home, Appointments, Feedback, and Dashboard.

2. **Authentication**:
   - Click the profile icon or "Login/Sign Up" button to open the `AuthDialog`.
   - Log in with an existing account or sign up with a new username, email, and password.
   - After logging in, the user’s name appears in the app bar, and the dashboard becomes accessible.

3. **Booking an Appointment**:
   - Navigate to the Appointments tab.
   - Select a department, doctor, appointment type, and enter a reason for the visit.
   - Submit to receive a confirmation and view the receipt on the `AppointmentReceiptPage`.

4. **Submitting Feedback**:
   - Go to the Feedback tab (requires login).
   - Rate your experience (1-5 stars) and provide comments.
   - Submit to save feedback, which appears in the Dashboard.

5. **Dashboard**:
   - View your profile, appointment history, and submitted feedback.
   - Explore charts showing appointments by department, patient satisfaction trends, and appointment status.

6. **Text Size Adjustment**:
   - Use the floating action buttons to increase, decrease, or reset text size for better readability.

## Development Notes

### Design Choices
- **Responsive Design**: The app uses `LayoutBuilder` to adjust layouts based on screen size, ensuring a consistent experience on mobile and tablet devices.
- **Theming**: A custom `ThemeData` with indigo as the primary color and Poppins as the font family provides a professional and cohesive look.
- **State Management**: The `provider` package is used for efficient state management, with separate providers for authentication (`AuthService`), appointments (`AppointmentService`), feedback (`FeedbackService`), and text scaling (`TextSizeProvider`).
- **Accessibility**: Text size adjustment enhances usability for users with visual impairments.
- **Animations**: Subtle animations (e.g., `AnimatedOpacity`, `AnimatedSlide`) improve the user experience without overwhelming the interface.

### Known Limitations
- **Local Storage**: User data, appointments, and feedback are stored locally using `shared_preferences`, which is not suitable for production-scale apps. Consider integrating a backend (e.g., Firebase) for persistent storage.
- **Firebase Integration**: The `firebase_core` package is included but not used. Full Firebase integration is needed for features like cloud-based authentication or data storage.
- **Error Handling**: Basic error handling is implemented, but more robust validation and error messages could improve user experience.

### Future Improvements
- **Backend Integration**: Replace `shared_preferences` with a backend solution (e.g., Firebase Firestore) for scalable data storage.
- **Enhanced Authentication**: Implement password recovery, email verification, and OAuth providers (e.g., Google, Facebook).
- **Push Notifications**: Add notifications for appointment reminders or feedback confirmation.
- **Advanced Charts**: Expand data visualizations with more interactive charts or filters.
- **Testing**: Add unit and widget tests using `flutter_test` to ensure code reliability.

## Contributing

Contributions are welcome! To contribute:
1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/your-feature`).
3. Commit your changes (`git commit -m 'Add your feature'`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a pull request.

Please ensure your code follows the project's linting rules (`flutter_lints`) and includes appropriate documentation.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For inquiries, contact the Global Care Medical Center team:
- **Address**: J. Yulo Avenue, Brgy. Canlubang
- **Phone**: (049) 520-5626
- **Email**: gcmccanlubang@gmail.com

© 2025 Global Care Medical Center. All rights reserved.
