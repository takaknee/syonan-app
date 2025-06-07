# Makefile for syonan-app development tasks
# Provides convenient commands for common development operations

.PHONY: help format format-check lint test build clean setup

# Default target
help:
	@echo "🔧 Syonan App - Development Commands"
	@echo "=================================="
	@echo ""
	@echo "Available commands:"
	@echo "  format        Format all Dart code"
	@echo "  format-check  Check if code needs formatting"
	@echo "  lint          Run Dart/Flutter analysis"
	@echo "  test          Run all tests"
	@echo "  build         Build the app (web)"
	@echo "  clean         Clean build artifacts"
	@echo "  setup         Set up development environment"
	@echo "  help          Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make format       # Format all code"
	@echo "  make lint         # Check code quality"
	@echo "  make test         # Run tests"

# Formatting commands
format:
	@echo "🎨 Formatting Dart code..."
	@if command -v dart >/dev/null 2>&1; then \
		dart format .; \
		echo "✅ Code formatting completed!"; \
	elif command -v flutter >/dev/null 2>&1; then \
		flutter format .; \
		echo "✅ Code formatting completed!"; \
	else \
		echo "❌ Error: Neither 'dart' nor 'flutter' command found!"; \
		echo "Please install Flutter SDK and ensure it's in your PATH."; \
		exit 1; \
	fi

format-check:
	@echo "🔍 Checking code formatting..."
	@./scripts/format.sh check

# Code quality
lint:
	@echo "🔍 Running code analysis..."
	@if command -v flutter >/dev/null 2>&1; then \
		flutter analyze; \
	elif command -v dart >/dev/null 2>&1; then \
		dart analyze; \
	else \
		echo "❌ Error: Neither 'dart' nor 'flutter' command found!"; \
		exit 1; \
	fi

# Testing
test:
	@echo "🧪 Running tests..."
	@if command -v flutter >/dev/null 2>&1; then \
		flutter test; \
	else \
		echo "❌ Error: Flutter command not found!"; \
		exit 1; \
	fi

# Building
build:
	@echo "🏗️ Building web app..."
	@if command -v flutter >/dev/null 2>&1; then \
		flutter build web --release; \
		echo "✅ Build completed! Check build/web/"; \
	else \
		echo "❌ Error: Flutter command not found!"; \
		exit 1; \
	fi

# Cleanup
clean:
	@echo "🧹 Cleaning build artifacts..."
	@if command -v flutter >/dev/null 2>&1; then \
		flutter clean; \
		echo "✅ Clean completed!"; \
	else \
		echo "⚠️ Flutter command not found, manual cleanup:"; \
		echo "  rm -rf build/"; \
		echo "  rm -rf .dart_tool/"; \
	fi

# Development setup
setup:
	@echo "⚙️ Setting up development environment..."
	@if command -v flutter >/dev/null 2>&1; then \
		flutter doctor; \
		flutter pub get; \
		echo "✅ Setup completed!"; \
	else \
		echo "❌ Error: Flutter command not found!"; \
		echo "Please install Flutter SDK first:"; \
		echo "  https://flutter.dev/docs/get-started/install"; \
		exit 1; \
	fi

# Quality assurance - run all checks
qa: format-check lint test
	@echo "✅ All quality checks passed!"