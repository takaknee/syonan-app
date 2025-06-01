# GitHub Copilot Instructions for Flutter Development

## Context
You are working on a Flutter mobile application called "syonan-app" designed for a daughter. The app should be family-friendly, educational, and engaging.

## Code Generation Guidelines

### When generating Flutter code:
1. Always import necessary packages at the top
2. Use Material Design 3 components when available
3. Implement proper error handling
4. Add meaningful comments for complex logic
5. Use const constructors for performance
6. Follow Flutter naming conventions

### State Management
- Use StatefulWidget for local state
- Consider Provider or Riverpod for app-wide state
- Implement proper lifecycle methods

### UI/UX Considerations
- Design for mobile-first experience
- Ensure accessibility features
- Use appropriate colors and fonts for children
- Implement responsive layouts

### Code Structure
- Separate UI components into reusable widgets
- Create models for data structures
- Use services for API calls and business logic
- Implement proper error boundaries

### Testing Approach
- Generate testable code with dependency injection
- Write descriptive test names
- Mock external dependencies
- Test both success and failure scenarios

## Example Patterns

### Widget Structure
```dart
class MyWidget extends StatelessWidget {
  const MyWidget({super.key, required this.title});
  
  final String title;
  
  @override
  Widget build(BuildContext context) {
    return // widget implementation
  }
}
```

### Service Pattern
```dart
abstract class MyService {
  Future<Result> performAction();
}

class MyServiceImpl implements MyService {
  @override
  Future<Result> performAction() async {
    // implementation
  }
}
```