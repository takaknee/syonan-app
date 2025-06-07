#!/bin/bash

# Dart Code Formatting Script
# This script helps fix formatting issues in the syonan-app project

echo "🔧 Syonan App - Code Formatting Helper"
echo "======================================"
echo ""

# Check if dart/flutter is available
if command -v dart >/dev/null 2>&1; then
    DART_CMD="dart"
elif command -v flutter >/dev/null 2>&1; then
    DART_CMD="flutter"
else
    echo "❌ Error: Neither 'dart' nor 'flutter' command found!"
    echo ""
    echo "🔧 Possible solutions:"
    echo "1. Install Flutter SDK: https://flutter.dev/docs/get-started/install"
    echo "2. Add Flutter to your PATH"
    echo "3. Run in CI environment with Flutter pre-installed"
    echo ""
    echo "⚠️ In CI environments without Flutter, this is expected behavior."
    echo "The workflow will continue and skip formatting checks."
    exit 1
fi

echo "📋 Using: $DART_CMD"
echo ""

# Function to format code
format_code() {
    echo "🎨 Formatting Dart code..."
    echo ""
    
    if [ "$DART_CMD" = "dart" ]; then
        $DART_CMD format .
    else
        $DART_CMD format .
    fi
    
    echo ""
    echo "✅ Code formatting completed!"
}

# Function to check formatting
check_formatting() {
    echo "🔍 Checking code formatting..."
    echo ""
    
    if [ "$DART_CMD" = "dart" ]; then
        if $DART_CMD format --dry-run . 2>&1 | grep -q "Formatted"; then
            echo "⚠️ Some files need formatting:"
            $DART_CMD format --dry-run . 2>&1 | grep "Formatted"
            echo ""
            echo "Run '$0 fix' to automatically format these files."
            return 1
        else
            echo "✅ All files are properly formatted!"
            return 0
        fi
    else
        # Flutter doesn't have --dry-run, so we'll use dart if available
        if command -v dart >/dev/null 2>&1; then
            if dart format --dry-run . 2>&1 | grep -q "Formatted"; then
                echo "⚠️ Some files need formatting:"
                dart format --dry-run . 2>&1 | grep "Formatted"
                echo ""
                echo "Run '$0 fix' to automatically format these files."
                return 1
            else
                echo "✅ All files are properly formatted!"
                return 0
            fi
        else
            echo "🔧 Cannot check formatting without dart command. Running format..."
            format_code
            return 0
        fi
    fi
}

# Function to show help
show_help() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  check    Check if code needs formatting (default)"
    echo "  fix      Automatically format all Dart code"
    echo "  help     Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0           # Check formatting"
    echo "  $0 check     # Check formatting"
    echo "  $0 fix       # Fix formatting issues"
    echo ""
    echo "This script helps maintain consistent code formatting"
    echo "for the syonan-app Flutter project."
}

# Main script logic
case "$1" in
    "fix")
        format_code
        ;;
    "check")
        check_formatting
        ;;
    "help"|"--help"|"-h")
        show_help
        ;;
    "")
        check_formatting
        ;;
    *)
        echo "❌ Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac