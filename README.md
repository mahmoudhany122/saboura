# 🎓 Saboura (سبورة) - Modern LMS & Gamified Learning Platform

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase&logoColor=ffca28)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Clean Architecture](https://img.shields.io/badge/Clean-Architecture-green?style=for-the-badge)

**Saboura** is a comprehensive, high-performance Learning Management System (LMS) specifically designed to provide an engaging and gamified educational experience for children while offering robust management tools for teachers.

---

## 🌟 Key Features

### 👨‍🏫 For Teachers
- **Comprehensive Dashboard**: Track student enrollments and course performance.
- **Dynamic Course Creation**: Build full courses with integrated modules.
- **Integrated Lessons**: Add YouTube videos, upload/link PDF materials, and create interactive quizzes.
- **Gamified Quiz Builder**: Create quizzes with 4 unique themes (Space, Car Racing, Monkey, Desert).
- **Real-time Results**: Monitor student quiz scores and completion dates instantly.
- **Cloud Storage**: Upload and manage educational assets via Firebase.

### 👶 For Students (Gamified Experience)
- **Interactive Home**: Explore available courses with categorized filters.
- **Engagement Quizzes**: Solve tests inside game-like environments (e.g., racing cars move as you answer correctly).
- **Progress Tracking**: Visual progress bars and "Lesson Completed" indicators for every course.
- **Leaderboard**: Compete with friends and see rankings based on points earned.
- **Seamless Learning**: Watch videos and read PDFs directly within the app using professional viewers.

### 🛠 System Wide
- **Multi-Auth**: Support for Email/Password and **Google Sign-In**.
- **Push Notifications**: Instant alerts for new courses, lessons, or quiz results with **custom sounds**.
- **Localization**: Full support for **Arabic** and **English** languages.
- **Theming**: Elegant **Light** and **Dark** modes with persistent storage.
- **Responsive UI**: Pixel-perfect design across all mobile devices using `flutter_screenutil`.

---

## 🏗 Architecture & Best Practices

The project strictly follows **Clean Architecture** principles to ensure scalability and maintainability:

- **Data Layer**: API implementations, Firebase repositories, and data models.
- **Domain Layer**: Core business logic, entities, and repository interfaces.
- **Presentation Layer**: UI Widgets, Screens, and State Management using **Bloc/Cubit**.
- **SOLID Principles**: Every component has a single responsibility.
- **Dependency Injection**: Managed by **GetIt**.
- **Performance Optimized**: Lazy loading, image caching, and efficient memory management (Controller disposal).

---

## 🚀 Tech Stack

| Feature | Library/Technology |
| :--- | :--- |
| **Framework** | Flutter (Dart) |
| **Backend** | Firebase Auth, Firestore, Storage |
| **State Management** | Flutter Bloc / Cubit |
| **Service Locator** | GetIt |
| **Networking** | Dio |
| **Notifications** | Firebase Messaging & Local Notifications |
| **PDF Viewer** | Syncfusion Flutter PDF Viewer |
| **Video Player** | Youtube Player Flutter |
| **Animations** | AnimateDo, Lottie, Shimmer |
| **Local Storage** | SharedPreferences |

---

## 📂 Project Structure

```text
lib/
├── core/               # Shared logic, themes, routing, and DI
├── features/           # Modular features
│   ├── auth/           # Login, Signup, Role Selection
│   ├── courses/        # Dashboard, Add Course, Lessons, Quizzes
│   ├── home/           # Main Layouts (Teacher/Student)
│   ├── settings/       # App Settings (Theme, Language)
│   └── splash/         # Entry screen
└── main.dart           # App entry point
```

---

## ⚙️ Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/saboura.git
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup:**
   - Add your `google-services.json` to `android/app/`.
   - Enable Auth (Email, Google) and Firestore in Firebase Console.
   - Set up Firebase Storage for file uploads.

4. **Run the app:**
   ```bash
   flutter run
   ```

---

## 🤝 Contributing

Contributions are welcome! If you'd like to improve Saboura, please fork the repo and create a pull request.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
**Saboura** - Empowering the next generation through gamified education. 🚀
