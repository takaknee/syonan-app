#!/bin/bash

# Environment Check Script for syonan-app
# This script checks the development environment status

echo "🔍 Syonan App - Environment Check"
echo "================================="
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print status messages
print_status() {
    echo "📋 $1"
}

print_success() {
    echo "✅ $1"
}

print_warning() {
    echo "⚠️ $1"
}

print_error() {
    echo "❌ $1"
}

# Check environment type
if [ -n "$CI" ] || [ -n "$GITHUB_ACTIONS" ]; then
    print_status "Environment: CI/CD (GitHub Actions)"
    CI_MODE=true
else
    print_status "Environment: Local Development"
    CI_MODE=false
fi
echo ""

# Check Flutter/Dart installation
print_status "Checking Flutter/Dart installation..."
if command_exists flutter; then
    print_success "Flutter found: $(flutter --version 2>/dev/null | head -n1 || echo 'version check failed')"
    FLUTTER_OK=true
elif command_exists dart; then
    print_success "Dart found: $(dart --version 2>/dev/null || echo 'version check failed')"
    print_warning "Flutter not found, but Dart is available"
    FLUTTER_OK=partial
else
    if [ "$CI_MODE" = true ]; then
        print_warning "Flutter/Dart not found (expected in this CI environment)"
    else
        print_error "Flutter/Dart not found - please install Flutter SDK"
        echo "  Visit: https://flutter.dev/docs/get-started/install"
    fi
    FLUTTER_OK=false
fi
echo ""

# Check project structure
print_status "Checking project structure..."
if [ -f "pubspec.yaml" ]; then
    print_success "pubspec.yaml found"
else
    print_error "pubspec.yaml not found - not a Flutter project?"
fi

if [ -d "lib" ]; then
    print_success "lib/ directory found"
else
    print_warning "lib/ directory not found"
fi

if [ -d "test" ]; then
    print_success "test/ directory found"
else
    print_warning "test/ directory not found"
fi
echo ""

# Check development tools
print_status "Checking development tools..."
if [ -f "Makefile" ]; then
    print_success "Makefile found"
else
    print_warning "Makefile not found"
fi

if [ -f "scripts/format.sh" ]; then
    print_success "Format script found"
else
    print_warning "Format script not found"
fi

if [ -f ".githooks/pre-commit" ]; then
    print_success "Pre-commit hooks installed"
else
    print_warning "Pre-commit hooks not installed"
fi
echo ""

# Summary and recommendations
print_status "Summary and Recommendations:"
echo ""

if [ "$CI_MODE" = true ]; then
    echo "🔧 CI/CD Environment:"
    echo "  - Quality checks will run with graceful fallbacks"
    echo "  - Some checks may be skipped due to environment limitations"
    echo "  - This is expected behavior in the current CI configuration"
elif [ "$FLUTTER_OK" = true ]; then
    echo "🎯 Development Environment Ready:"
    echo "  - Run 'make qa' to check code quality"
    echo "  - Run 'make setup' for complete development setup"
    echo "  - Run 'make help' to see all available commands"
elif [ "$FLUTTER_OK" = partial ]; then
    echo "⚠️ Partial Setup:"
    echo "  - Install Flutter for full functionality"
    echo "  - Some features may work with Dart only"
    echo "  - Run 'make setup' after installing Flutter"
else
    echo "🔧 Setup Required:"
    echo "  - Install Flutter SDK first"
    echo "  - Run 'make setup' after installation"
    echo "  - See README.md for detailed setup instructions"
fi
echo ""

# Exit with appropriate code
if [ "$CI_MODE" = true ]; then
    # In CI, always exit successfully
    exit 0
elif [ "$FLUTTER_OK" = true ]; then
    # Local with Flutter - all good
    exit 0
else
    # Local without Flutter - indicate setup needed
    exit 1
fi