# 📜 Saboura Project Coding Standards & Architecture

This document defines the architectural patterns, coding standards, and best practices used in this project. Use this as a reference for any future feature development or new projects.

---

## 🏗 1. Architecture: Clean Architecture (Feature-First)
We follow a strict Clean Architecture pattern organized by features. Each feature must contain:

- **`data/`**: 
  - `models/`: Data classes with `fromJson`/`toJson`.
  - `repos/`: Implementation of domain repositories.
  - `datasources/`: (Optional) Remote or local data providers.
- **`domain/`**:
  - `entities/`: Pure business objects.
  - `repos/`: Abstract interfaces for repositories.
- **`presentation/`**:
  - `logic/`: Bloc/Cubit files for state management.
  - `screens/`: Main page widgets.
  - `widgets/`: Small, reusable UI components specific to the feature.

---

## 🛠 2. Tech Stack & Tools
- **State Management**: `flutter_bloc` (Cubit).
- **Dependency Injection**: `get_it` (Service Locator).
- **Navigation**: Named Routes with a central `AppRouter`.
- **Backend**: Firebase (Auth, Firestore, Storage, Messaging).
- **Networking**: `dio` for external APIs.
- **UI/UX**: `flutter_screenutil` (Responsiveness), `cached_network_image` (Caching), `shimmer` (Loading states), `animate_do` (Animations).
- **Localization**: `easy_localization` (Multi-language support).

---

## 📏 3. Coding Principles (SOLID & Clean Code)
1. **Single Responsibility (SRP)**: Each widget or class must have one job. Logic belongs in Cubits, not in UI.
2. **Reusability**: Extract repetitive UI elements into the `widgets/` folder or `core/widgets/`.
3. **Naming Convention**: 
   - Variables/Functions: `camelCase`.
   - Classes: `PascalCase`.
   - Files: `snake_case`.
4. **Memory Management**: Always `dispose()` controllers (TextEditingController, AnimationController, Timer) in `StatefulWidget`.
5. **Data Flow**: Use `dartz` (`Either<Failure, Success>`) for handling repository responses.

---

## 🎨 4. UI & UX Standards
- **Responsiveness**: Use `.h`, `.w`, `.sp` from `ScreenUtil`.
- **Spacing**: Use `verticalSpace()` and `horizontalSpace()` helpers instead of `SizedBox`.
- **Theming**: All colors must come from `ColorsManager` and styles from `TextStyles`.
- **Loading**: Use **Shimmer** effects for data fetching instead of simple indicators.
- **Error Handling**: Show user-friendly SnackBars or Error Widgets with "Retry" options.

---

## 📂 5. Global Core Folder
The `core/` folder contains shared logic:
- `di/`: Service locator setup.
- `helpers/`: Utilities like `cache_helper`, `notification_helper`.
- `routing/`: `app_router.dart` and `routes.dart`.
- `theming/`: `colors.dart`, `styles.dart`, and `themes.dart`.
- `widgets/`: App-wide reusable components (AppButton, AppTextField).

---

## 🚀 6. Performance Optimization
- **Lazy Initialization**: Use `LazySingleton` in GetIt to save memory.
- **Firebase Optimization**: Filter queries on the server side (`where()`) to reduce read costs.
- **Image Caching**: Always use `CachedNetworkImage` for network assets.
- **Parallel Init**: Use `Future.wait` or background initialization in `main()` to prevent Splash Screen hangs.

---
**Author Note**: Follow these rules strictly to maintain a production-grade codebase. 🚀
