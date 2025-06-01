# Flutter Development Instructions

## Project Overview
This is a Flutter app project for my daughter (syonan-app).

## Development Guidelines

### Code Style
- Follow Dart official style guide
- Use meaningful variable and function names
- Keep functions small and focused
- Use proper commenting for complex logic

### Flutter Best Practices
- Use const constructors where possible
- Implement proper state management
- Follow Material Design guidelines
- Ensure responsive design for different screen sizes

### GitHub Copilot Usage
- Be specific in your comments when asking for code suggestions
- Use descriptive function and variable names to get better suggestions
- Break down complex tasks into smaller, well-defined functions
- Use TODO comments to guide Copilot for implementation tasks

### Testing
- Write unit tests for business logic
- Write widget tests for UI components
- Ensure tests are maintainable and readable

### Performance
- Avoid unnecessary rebuilds
- Use appropriate widgets for the use case
- Profile app performance regularly
- Optimize images and assets

## File Structure
```
lib/
├── main.dart
├── models/
├── screens/
├── widgets/
├── services/
└── utils/
```

## Commit Message Format
- feat: new feature
- fix: bug fix
- docs: documentation changes
- style: formatting changes
- refactor: code refactoring
- test: adding tests
- chore: maintenance tasks