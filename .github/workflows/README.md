# GitHub Actions Workflows

This directory contains the GitHub Actions workflows for the Syonan App project.

## Workflows Overview

### Core Workflows

#### 1. CI/CD Pipeline (`ci-cd.yml`)
**Main workflow for continuous integration and deployment**

- **Triggers**: Push to main/develop, Pull requests, Manual dispatch
- **Jobs**:
  - `setup`: Environment setup and Flutter installation
  - `quality-check`: Code quality checks (formatting, analysis, tests)
  - `build-web`: Build Flutter web application
  - `deploy`: Deploy to GitHub Pages (main branch only)

#### 2. Auto-Fix (`auto-fix.yml`)
**Automatic code quality fixes**

- **Triggers**: Issue comments with `/auto-fix`, Manual dispatch
- **Features**:
  - Automatic code formatting
  - Const modifier additions
  - Analysis issue fixes
  - Commit and push changes

#### 3. Configuration Validation (`validate-config.yml`)
**Validate project configuration files**

- **Triggers**: Changes to `.github/`, `.vscode/`, `pubspec.yaml`
- **Checks**:
  - YAML syntax validation
  - pubspec.yaml structure
  - Basic security review

### Support Files

#### 4. Jekyll (Disabled) (`jekyll-gh-pages.yml`)
**Placeholder to prevent Jekyll conflicts**

- **Status**: Disabled
- **Purpose**: Prevent GitHub from automatically running Jekyll

## Custom Actions

### Setup Flutter (`actions/setup-flutter/`)
Reusable action for Flutter environment setup with fallback methods.

**Features**:
- Primary setup using official Flutter action
- Fallback manual installation
- Comprehensive availability checking
- Caching support

### Flutter Quality Check (`actions/flutter-quality-check/`)
Reusable action for code quality checks and fixes.

**Features**:
- Code formatting checks and fixes
- Static analysis
- Test execution
- Automatic const modifier additions

## Usage

### Running CI/CD Pipeline
The pipeline runs automatically on:
- Push to `main` or `develop` branches
- Pull requests to `main`
- Manual dispatch from Actions tab

### Using Auto-Fix
1. **Via Comment**: Add a comment with `/auto-fix` in any issue or PR
2. **Via Manual Dispatch**: Run from Actions tab with options:
   - `all`: Apply all fixes
   - `format`: Format code only
   - `analysis`: Fix analysis issues only
   - `const`: Add const modifiers only

### Commands Available

| Command | Description |
|---------|-------------|
| `/auto-fix` | Apply all available fixes |
| `/auto-fix format` | Format code only |
| `/auto-fix analysis` | Fix analysis issues only |
| `/auto-fix const` | Add const modifiers only |

## Development Notes

### Best Practices
1. **Reusable Actions**: Common functionality is extracted into custom actions
2. **Error Handling**: All workflows include proper error handling and fallbacks
3. **Security**: Minimal permissions and secure token usage
4. **Performance**: Efficient caching and parallel execution where possible

### Troubleshooting

#### Flutter Setup Issues
If Flutter setup fails, the workflows will:
1. Attempt primary setup using official action
2. Fall back to manual installation
3. Skip Flutter-specific steps if unavailable
4. Provide clear error messages

#### Permission Issues
Ensure the repository has:
- Pages enabled in Settings
- Actions permissions set to appropriate level
- Workflow permissions for writing to repository

### Monitoring
- Check the Actions tab for workflow runs
- Review job logs for detailed information
- Monitor deployment status in Environments tab

## Migration Notes

This refactored workflow system replaces the previous complex multi-file setup with:
- **Simplified Structure**: 3 main workflows instead of 7
- **Reusable Components**: Custom actions for common tasks
- **Better Error Handling**: Robust fallback mechanisms
- **Cleaner Code**: Consistent naming and structure
- **Enhanced Security**: Minimal permissions and proper token usage

The previous workflows have been consolidated and their functionality preserved while improving maintainability and reliability.
