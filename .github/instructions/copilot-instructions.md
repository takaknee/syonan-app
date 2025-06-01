# GitHub Copilot Instructions for Flutter Development

## Project Context
This is a Flutter application for my daughter. The app should be family-friendly and educational.

## Code Style Guidelines

### Flutter/Dart
- Use flutter_lints package for consistent code formatting
- Follow effective Dart style guide
- Prefer composition over inheritance
- Use meaningful variable and function names in English
- Add documentation comments for public APIs
- Use const constructors where possible for performance

### Architecture
- Follow Clean Architecture principles
- Use Provider/Riverpod for state management
- Separate business logic from UI components
- Create reusable widgets
- Use proper folder structure (lib/features/, lib/core/, lib/shared/)

### File Organization
```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── utils/
│   └── theme/
├── features/
│   └── [feature_name]/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── shared/
    ├── widgets/
    └── services/
```

## Development Practices
- Write unit tests for business logic
- Write widget tests for UI components
- Use meaningful commit messages in Japanese
- Create PRs with clear descriptions
- Use issue templates for feature requests and bug reports

## UI/UX Guidelines
- Design should be child-friendly with bright colors
- Use Material Design 3 principles
- Ensure accessibility (screen reader support, proper contrast)
- Support both light and dark themes
- Design for mobile-first approach

## Dependencies
- Prefer well-maintained packages
- Check package popularity and maintenance status
- Add dependency rationale in pubspec.yaml comments
- Keep dependencies up to date

## Security
- Never commit API keys or sensitive data
- Use environment variables for configuration
- Validate all user inputs
- Follow Flutter security best practices