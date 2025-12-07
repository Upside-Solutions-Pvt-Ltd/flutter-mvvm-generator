#!/bin/bash

# Stop script on any error
set -e

# --- Input Validation ---
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <base_path> <feature_name>"
    echo "Example: $0 profile user_profile"
    exit 1
fi

# --- File & Path Validation ---
if [ ! -f "pubspec.yaml" ]; then
    echo "Error: pubspec.yaml not found. Run this script from the project root."
    exit 1
fi

SERVICE_LOCATOR_FILE="lib/service_locator.dart"
MAIN_DART_FILE="lib/main.dart"

if [ ! -f "$SERVICE_LOCATOR_FILE" ]; then
    echo "Error: Service locator file not found at $SERVICE_LOCATOR_FILE"
    exit 1
fi

if [ ! -f "$MAIN_DART_FILE" ]; then
    echo "Error: main.dart file not found at $MAIN_DART_FILE"
    exit 1
fi


# --- Variables ---
BASE_PATH=$1
FEATURE_NAME=$2 # e.g., user_profile
FEATURE_DIR="lib/features/$BASE_PATH"

# Convert snake_case to PascalCase (e.g., user_profile -> UserProfile)
# Use awk for a cross-platform solution
CLASS_NAME=$(echo "$FEATURE_NAME" | awk -F_ '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1' OFS="")

SCREEN_CLASS_NAME="${CLASS_NAME}Screen"
VIEWMODEL_CLASS_NAME="${CLASS_NAME}ViewModel"

SCREEN_FILE_NAME="${FEATURE_NAME}_screen.dart"
VIEWMODEL_FILE_NAME="${FEATURE_NAME}_viewmodel.dart"

SCREEN_FILE_PATH="$FEATURE_DIR/$SCREEN_FILE_NAME"
VIEWMODEL_FILE_PATH="$FEATURE_DIR/$VIEWMODEL_FILE_NAME"

# Get project name from pubspec.yaml
PROJECT_NAME=$(grep '^name:' pubspec.yaml | cut -d ' ' -f 2)

# Create package-style import path
VIEWMODEL_PATH_NO_LIB=${VIEWMODEL_FILE_PATH#lib/}
VIEWMODEL_IMPORT_PATH="package:$PROJECT_NAME/$VIEWMODEL_PATH_NO_LIB"


# --- Create Directory ---
mkdir -p "$FEATURE_DIR"
echo "Directory created: $FEATURE_DIR"

# --- Create Screen File ---
cat <<EOF > "$SCREEN_FILE_PATH"
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:$PROJECT_NAME/features/base_screen.dart';
import './$VIEWMODEL_FILE_NAME';

class $SCREEN_CLASS_NAME extends BaseScreen {
  const $SCREEN_CLASS_NAME({super.key});

  @override
  Widget mainContent(BuildContext context) {
    return Consumer<$VIEWMODEL_CLASS_NAME>(
      builder: (context, model, child) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Text("Home")],
          ),
        );
      },
    );
  }
}
EOF

echo "File created: $SCREEN_FILE_PATH"

# --- Create ViewModel File ---
cat <<EOF > "$VIEWMODEL_FILE_PATH"
import 'package:$PROJECT_NAME/features/base_viewmodel.dart';

class $VIEWMODEL_CLASS_NAME extends BaseViewmodel {

}
EOF

echo "File created: $VIEWMODEL_FILE_PATH"

# --- Use mktemp to create a safe temporary file ---
TEMP_FILE=$(mktemp)
# Ensure temp file is removed on exit
trap 'rm -f "$TEMP_FILE"' EXIT


# --- Update Service Locator (Using awk) ---
echo "Updating $SERVICE_LOCATOR_FILE..."

# Add import statement
awk -v line="import '$VIEWMODEL_IMPORT_PATH';" '
{
    if ($0 ~ /\/\/ --- VIEWMODEL IMPORTS END ---/) {
        print line
    }
    print $0
}
' "$SERVICE_LOCATOR_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$SERVICE_LOCATOR_FILE"

# Add registration line
awk -v line="   serviceLocator.registerLazySingleton<${VIEWMODEL_CLASS_NAME}>(() => ${VIEWMODEL_CLASS_NAME}());" '
{
    if ($0 ~ /\/\/ --- VIEWMODEL REGISTRATION END ---/) {
        print line
    }
    print $0
}
' "$SERVICE_LOCATOR_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$SERVICE_LOCATOR_FILE"


# --- Update main.dart (Using awk) ---
echo "Updating $MAIN_DART_FILE..."

# Add import statement
awk -v line="import '$VIEWMODEL_IMPORT_PATH';" '
{
    if ($0 ~ /\/\/ --- PROVIDER IMPORTS END ---/) {
        print line
    }
    print $0
}
' "$MAIN_DART_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$MAIN_DART_FILE"

# Add provider to list
awk -v line="        ChangeNotifierProvider(create: (_) => serviceLocator<${VIEWMODEL_CLASS_NAME}>())," '
{
    if ($0 ~ /\/\/ --- PROVIDERS LIST END ---/) {
        print line
    }
    print $0
}
' "$MAIN_DART_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$MAIN_DART_FILE"


echo "✅ Successfully created and registered feature '$FEATURE_NAME'"
