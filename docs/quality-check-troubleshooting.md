# Quality Check Troubleshooting Guide

This guide helps troubleshoot quality check issues in the syonan-app project.

## Quick Diagnosis

Run the environment check to see what's available:

```bash
make check-env
```

## Common Issues and Solutions

### 1. "Flutter/Dart not found" Error

**Problem**: Quality checks fail because Flutter or Dart is not installed.

**Solutions**:

**For Local Development:**
```bash
# Install Flutter SDK
# Visit: https://flutter.dev/docs/get-started/install

# After installation, verify:
flutter doctor

# Then run setup:
make setup
```

**For CI/CD**: This is expected behavior. The tools will gracefully skip checks.

### 2. Format Check Failures

**Problem**: Code formatting issues detected.

**Quick Fix**:
```bash
# Check what needs formatting:
make format-check

# Fix formatting automatically:
make format
```

**Prevention**:
```bash
# Install pre-commit hooks:
./scripts/install-hooks.sh

# Or run before commits:
make qa
```

### 3. Analysis Errors

**Problem**: `flutter analyze` or `dart analyze` reports issues.

**Solutions**:
```bash
# Run analysis to see issues:
make lint

# Fix issues manually, then verify:
make lint
```

### 4. Test Failures

**Problem**: Tests fail during quality checks.

**Solutions**:
```bash
# Run tests to see failures:
make test

# Fix failing tests, then verify:
make test
```

## Quality Check Commands

| Command | Purpose | Environment |
|---------|---------|-------------|
| `make qa` | Run all quality checks | Local + CI |
| `make format-check` | Check code formatting | Local + CI |
| `make format` | Fix code formatting | Local + CI |
| `make lint` | Run code analysis | Local + CI |
| `make test` | Run tests | Local + CI |
| `make check-env` | Check environment status | Local + CI |

## CI/CD Behavior

In CI environments without Flutter:
- ✅ Quality checks run with graceful fallbacks
- ✅ Build continues instead of failing
- ✅ Clear messages explain what was skipped
- ✅ Exit codes indicate success when appropriate

## Pre-commit Prevention

To prevent quality check failures before they reach CI:

1. **Install pre-commit hooks** (recommended):
   ```bash
   ./scripts/install-hooks.sh
   ```

2. **Manual checks before commits**:
   ```bash
   make qa
   ```

3. **VS Code integration**: Use the configured tasks in Command Palette

## Debugging Steps

1. **Check environment**:
   ```bash
   make check-env
   ```

2. **Run individual checks**:
   ```bash
   make format-check
   make lint
   make test
   ```

3. **Check tool availability**:
   ```bash
   which flutter dart
   flutter doctor
   ```

4. **Verify project structure**:
   ```bash
   ls -la pubspec.yaml lib/ test/
   ```

## Environment Variables

The tools recognize these environment variables:

- `CI`: Indicates CI environment (enables graceful fallbacks)
- `GITHUB_ACTIONS`: Indicates GitHub Actions (enables graceful fallbacks)

## Support

For additional help:
- Check the main README.md
- Review the docs/ directory
- Use GitHub Issues for reporting problems

## Examples

**Local development workflow**:
```bash
# Initial setup
make setup

# Before each commit
make qa

# Fix any issues
make format  # for formatting
# manually fix analysis/test issues
```

**CI troubleshooting**:
```bash
# In CI logs, look for:
CI=true make qa

# Should show graceful fallbacks, not hard failures
```