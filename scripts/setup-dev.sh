#!/bin/bash

# Development Environment Setup Script for syonan-app
# This script sets up the complete development environment including formatting checks

echo "🚀 Syonan App - Development Environment Setup"
echo "============================================="
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

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ] || [ ! -d ".git" ]; then
    print_error "Please run this script from the root of the syonan-app repository"
    exit 1
fi

print_status "Setting up syonan-app development environment..."
echo ""

# Step 1: Check Flutter installation
print_status "Step 1: Checking Flutter installation..."
if command_exists flutter; then
    print_success "Flutter found: $(flutter --version | head -n1)"
    
    # Run flutter doctor to check setup
    echo ""
    print_status "Running Flutter doctor..."
    flutter doctor
    echo ""
else
    print_error "Flutter not found in PATH"
    echo ""
    echo "Please install Flutter SDK:"
    echo "  https://flutter.dev/docs/get-started/install"
    echo ""
    echo "After installation, add Flutter to your PATH and run this script again."
    exit 1
fi

# Step 2: Install dependencies
print_status "Step 2: Installing Flutter dependencies..."
if flutter pub get; then
    print_success "Dependencies installed successfully"
else
    print_error "Failed to install dependencies"
    exit 1
fi
echo ""

# Step 3: Setup pre-commit hooks (with user confirmation)
print_status "Step 3: Setting up code quality checks..."
echo ""
echo "🛡️ To prevent CI/CD formatting errors, we recommend installing pre-commit hooks."
echo "These hooks will automatically check code formatting before each commit."
echo ""
read -p "Do you want to install pre-commit hooks? (Y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
    if [ -f "./scripts/install-hooks.sh" ]; then
        chmod +x ./scripts/install-hooks.sh
        if ./scripts/install-hooks.sh; then
            print_success "Pre-commit hooks installed successfully"
        else
            print_warning "Pre-commit hooks installation failed"
        fi
    else
        print_warning "Pre-commit hook installation script not found"
    fi
else
    print_warning "Pre-commit hooks not installed"
    echo ""
    echo "You can install them later by running:"
    echo "  ./scripts/install-hooks.sh"
    echo ""
    echo "Or manually check formatting before commits:"
    echo "  make format-check"
fi
echo ""

# Step 4: Run initial code quality checks
print_status "Step 4: Running initial code quality checks..."
echo ""

# Check formatting
print_status "Checking code formatting..."
if command_exists dart; then
    if dart format --line-length=120 --dry-run . 2>&1 | grep -q "Formatted"; then
        print_warning "Some files need formatting"
        echo ""
        echo "Files that need formatting:"
        dart format --line-length=120 --dry-run . 2>&1 | grep "Formatted"
        echo ""
        read -p "Do you want to fix formatting now? (Y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
            dart format --line-length=120 .
            print_success "Code formatting fixed"
        fi
    else
        print_success "Code formatting is good"
    fi
else
    print_warning "Dart command not available, skipping format check"
fi
echo ""

# Run analysis
print_status "Running code analysis..."
if flutter analyze --no-fatal-infos; then
    print_success "Code analysis passed"
else
    print_warning "Code analysis found issues (please review)"
fi
echo ""

# Step 5: Setup complete
print_success "Development environment setup complete!"
echo ""
echo "🎯 Quick Start Commands:"
echo "  make help          # Show all available commands"
echo "  make format-check  # Check code formatting"
echo "  make qa            # Run all quality checks"
echo "  flutter run -d web # Start development server"
echo ""
echo "📚 Documentation:"
echo "  docs/formatting-guide.md  # Formatting guidelines"
echo "  README.md                 # Project overview"
echo ""
echo "🚨 Before creating PRs, always run:"
echo "  make qa  # This prevents CI/CD formatting errors"
echo ""
echo "Happy coding! 🚀"