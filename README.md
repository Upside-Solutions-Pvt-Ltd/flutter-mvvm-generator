# Flutter Feature Generator 🚀

A robust, cross-platform shell script to automate the creation of MVVM features in Flutter. It generates boilerplate code for Screens and ViewModels and automatically handles dependency injection in `GetIt` and `Provider`.

## ✨ Features

* **⚡ Automated Creation**: Generates a feature folder with `Screen` and `ViewModel` files.
* **🏗️ Architecture Standard**: Follows the MVVM pattern.
* **🔌 Auto-Wiring**:
    * Automatically updates `service_locator.dart` (Imports & Registration).
    * Automatically updates `main.dart` (Imports & `MultiProvider` list).
* **🍎🐧 Cross-Platform**: Written with `awk` to ensure full compatibility with both **macOS** and **Linux**.

---

## 🛠️ Installation

1.  Download the `create_feature.sh` script and place it in the **root** of your Flutter project.
2.  Open your terminal in the project root and make the script executable:

```bash
chmod +x create_feature.sh

### 2. Add Markers (One-Time Setup)

You must add specific comments to your files so the script knows where to insert code.

**In `lib/service_locator.dart`:**

```dart
import 'package:get_it/get_it.dart';
// ... other imports
// --- VIEWMODEL IMPORTS ---

final locator = GetIt.instance;

void setupLocator() {
  // ... other registrations
  
  // --- VIEWMODEL REGISTRATION ---
}
```

**In `lib/main.dart`:**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ... other imports
// --- PROVIDER IMPORTS ---

void main() {
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ... other providers
        
        // --- PROVIDERS LIST ---
      ],
      child: const MaterialApp(home: HomeScreen()),
    );
  }
}
```

---

## 💻 Usage

Run the script from the root of your project:

```bash
./create_feature.sh <target_folder> <feature_name>
```

### Example

To create a **Biometric Setup** feature:

```bash
./create_feature.sh auth/biometric/setup biometric_setup
```

### Generated Output

1.  **Directory**: `lib/features/auth/biometric/setup/`
2.  **Screen**: `biometric_setup_screen.dart`
3.  **ViewModel**: `biometric_setup_viewmodel.dart`
4.  **Auto-Registration**: The ViewModel is automatically added to `service_locator.dart` and `main.dart`.
