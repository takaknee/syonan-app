---
name: Code Generation Request
about: Request GitHub Copilot to generate specific code
title: '[COPILOT] '
labels: ['copilot', 'code-generation']
assignees: ''

---

## Code Generation Request
A specific description of the code you want GitHub Copilot to generate.

## Context
- **File location:** [path where the code should be added/created]
- **Related components:** [list of existing components this code will interact with]
- **Dependencies:** [existing packages, services, or models this code depends on]

## Functional Requirements
- [ ] Requirement 1: [specific functionality]
- [ ] Requirement 2: [specific functionality]
- [ ] Requirement 3: [specific functionality]

## Technical Requirements
- [ ] Follow Flutter/Dart best practices
- [ ] Include proper error handling
- [ ] Add appropriate documentation/comments
- [ ] Ensure type safety
- [ ] Handle edge cases

## Code Style Requirements
- [ ] Use const constructors where possible
- [ ] Follow project naming conventions
- [ ] Include proper imports
- [ ] Add null safety
- [ ] Use meaningful variable names

## Testing Requirements
- [ ] Unit tests for business logic
- [ ] Widget tests for UI components
- [ ] Integration tests if applicable
- [ ] Mock dependencies appropriately

## Example Usage (if applicable)
```dart
// Example of how the generated code should be used
final myWidget = GeneratedWidget(
  parameter1: 'value1',
  parameter2: 42,
);
```

## Expected Output Structure
```dart
// Brief description of the expected code structure
class MyGeneratedClass {
  // Properties
  
  // Constructor
  
  // Methods
}
```

## Additional Context
Any additional information that would help Copilot generate better code.

## Copilot Instructions
**Generation Guidelines:**
1. Start with the public interface/API
2. Implement core functionality
3. Add error handling and validation
4. Include comprehensive documentation
5. Generate corresponding tests

**Code Quality Checklist:**
- [ ] Code follows Dart style guide
- [ ] All public APIs are documented
- [ ] Error cases are handled gracefully
- [ ] Code is testable and modular
- [ ] Performance considerations are addressed

**Review Criteria:**
- [ ] Code compiles without errors
- [ ] All tests pass
- [ ] Code meets functional requirements
- [ ] Code follows project conventions
- [ ] Documentation is complete and accurate