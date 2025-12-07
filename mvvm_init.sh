#!/bin/bash

# Stop on error
set -e

echo "🚀 Starting MVVM Project Initialization..."

# --- 1. Validate Tools & Environment ---

# Check if FVM is installed
if ! command -v fvm &> /dev/null; then
    echo "❌ Error: 'fvm' is not installed or not in your PATH."
    echo "   Please install it via: dart pub global activate fvm"
    exit 1
fi

# Check if this is a Flutter project
if [ ! -f "pubspec.yaml" ] || [ ! -f "lib/main.dart" ]; then
    echo "❌ Error: This does not appear to be a valid Flutter project root."
    echo "   (Missing pubspec.yaml or lib/main.dart)"
    exit 1
fi

echo "✅ Environment validated."

# --- 2. Flutter Version Management ---

echo "fetching available Flutter releases..."
# We use 'tail' to limit output because the list can be huge
fvm releases | tail -n 20

echo "------------------------------------------------"
read -p "👉 Enter preferred Flutter version (Press Enter for 'stable'): " SELECTED_VERSION
SELECTED_VERSION=${SELECTED_VERSION:-stable}

echo "⚙️  Configuring project to use Flutter $SELECTED_VERSION..."
fvm use "$SELECTED_VERSION" --force

# --- 3. Install Dependencies ---

echo "📦 Installing dependencies..."
# Added firebase_core because it is imported in your main.dart template
fvm flutter pub add provider get_it go_router firebase_core

# --- 4. Create Project Files ---

echo "📝 Generatng boilerplate files..."

# --- Create lib/router.dart (Required by main.dart) ---
# We create this so the project compiles immediately
cat <<EOF > lib/navigation_routes.dart
import 'package:go_router/go_router.dart';

import 'features/home/home_screen.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: "/",
      name: '/',
      builder: (context, state) {
        return const HomeScreen();
      },
    ),
  ],
);

EOF
echo "   - Created lib/navigation_routes.dart"

# --- Create lib/service_locator.dart ---
cat <<EOF > lib/service_locator.dart
import 'package:get_it/get_it.dart';
// --- VIEWMODEL IMPORTS ---
// --- VIEWMODEL IMPORTS END ---

final serviceLocator = GetIt.instance;

void setupServiceLocator() {
  // --- VIEWMODEL REGISTRATION ---
  // --- VIEWMODEL REGISTRATION END ---
}
EOF
echo "   - Created lib/service_locator.dart"

# --- Create lib/main.dart ---
cat <<EOF > lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import './service_locator.dart';
import './navigation_routes.dart';

// --- PROVIDER IMPORTS ---
// --- PROVIDER IMPORTS END ---

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Note: Firebase setup is commented out until you add google-services.json
  // await Firebase.initializeApp();
  setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // --- PROVIDERS LIST ---
        // --- PROVIDERS LIST END ---
      ],
      child: MaterialApp.router(
        routerConfig: router,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
      ),
    );
  }
}
EOF
echo "   - Overwritten lib/main.dart"

FEATURE_DIR="lib/features"
mkdir -p "$FEATURE_DIR"
echo "Directory created: $FEATURE_DIR"

# --- Create lib/feature/base_screen.dart ---
cat <<EOF > lib/features/base_screen.dart
import 'package:flutter/material.dart';

abstract class BaseScreen  extends StatelessWidget {
  const BaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return mainContent(context);
  }

  Widget mainContent(BuildContext context);
}
EOF
echo "   - Created lib/features/base_screen.dart"

# --- Create lib/feature/base_viewmodel.dart ---
cat <<EOF > lib/features/base_viewmodel.dart
import 'package:flutter/material.dart';

abstract class BaseViewmodel extends ChangeNotifier {}

EOF
echo "   - Created lib/features/base_viewmodel.dart"

chmod +x ./create_feature.sh
sh ./create_feature.sh home home
echo "   - Dummy home screen created."

echo "------------------------------------------------"
echo "✅ MVVM Initialization Complete!"
echo "👉 You can now use './create_feature.sh' to generate features or 'fvm flutter run' to run the application."
