# Flutter MVVM Automation Tools 🛠️

This repository contains a set of shell scripts to automate the setup and feature creation for Flutter projects using the MVVM architecture (Provider + GetIt + GoRouter).

## 📋 Prerequisites

* **Flutter SDK** installed.
* **FVM** (Flutter Version Management) installed (`dart pub global activate fvm`).
* **Bash** terminal (macOS, Linux, or WSL on Windows).

---

## 🚀 1. Project Initialization (`mvvm_init.sh`)

This script sets up FVM, installs dependencies, and creates the core boilerplate files (`main.dart`, `router.dart`, `service_locator.dart`) with the necessary **markers** for automation.
### 🛠️ Installation

1.  Download the `mvvm_init.sh` script and `create_feature.sh` script and place it in the **root** of your Flutter project.
2.  Open your terminal in the project root and make the script executable:

### 💻 Usage
Run the script from the root of your project
```bash
chmod +x mvvm_init.sh
./mvvm_init.sh
```

## Flutter Feature Generator 🚀

A robust, cross-platform shell script to automate the creation of MVVM features in Flutter. It generates boilerplate code for Screens and ViewModels and automatically handles dependency injection in `GetIt` and `Provider`.

### ✨ Features

* **⚡ Automated Creation**: Generates a feature folder with `Screen` and `ViewModel` files.
* **🏗️ Architecture Standard**: Follows the MVVM pattern.
* **🔌 Auto-Wiring**:
    * Automatically updates `service_locator.dart` (Imports & Registration).
    * Automatically updates `main.dart` (Imports & `MultiProvider` list).
* **🍎🐧 Cross-Platform**: Written with `awk` to ensure full compatibility with both **macOS** and **Linux**.

---

### 🛠️ Installation

1.  Download the `create_feature.sh` script and place it in the **root** of your Flutter project.
2.  Open your terminal in the project root and make the script executable:

```bash
chmod +x create_feature.sh
```
---

### 💻 Usage

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
