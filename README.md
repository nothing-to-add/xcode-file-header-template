# Xcode File Header Template Manager

A comprehensive macOS application for managing and applying file header templates in Xcode projects. This app provides both global and project-specific template management capabilities.

## Features

### 🌐 Global Templates
- Create and manage reusable header templates that work across all projects
- Built-in templates for Swift files (Default and Minimal)
- Customizable template variables (author, organization, Swift version, etc.)
- Export and import templates for sharing between machines

### 📁 Project-Specific Templates
- Create templates that are specific to individual projects
- Override global templates with project-specific ones
- Store project templates alongside your project files
- Automatically detect project structure and suggest appropriate templates

### ✨ Advanced Features
- **Template Editor**: Full-featured editor with syntax highlighting and live preview
- **Variable System**: Support for built-in variables (FILE_NAME, PROJECT_NAME, DATE, etc.) and custom variables
- **File Processing**: Batch apply templates to existing files with smart header detection
- **Project Integration**: Scan project directories and apply templates based on file extensions
- **Template Preview**: See exactly how your template will look before applying
- **Menu Integration**: Quick access via macOS menu bar commands

## Installation

1. Clone this repository
2. Open `xcode-file-header-template.xcodeproj` in Xcode
3. Build and run the project (⌘+R)
4. The app will appear in your Applications folder after building

## Usage

### Getting Started

1. **Launch the app**: The main interface shows two tabs - "Global Templates" and "Project Templates"
2. **Select a template**: Choose from existing templates or create new ones
3. **Preview changes**: Use the preview pane to see how your template will appear
4. **Apply to files**: Use project settings to batch process files

### Managing Global Templates

Global templates are available across all your projects and are stored in:
```
~/Library/Application Support/XcodeFileHeaderTemplate/GlobalTemplates.json
```

**To create a new global template:**
1. Switch to the "Global Templates" tab
2. Click "New Template"
3. Configure your template:
   - **Name**: Give your template a descriptive name
   - **File Extensions**: Specify which file types this applies to (e.g., "swift", "h", "m")
   - **Variables**: Set up custom variables for reusable content
   - **Content**: Write your template using variable placeholders

### Managing Project Templates

Project templates are specific to individual projects and stored as `.xcodeheader.json` in your project root.

**To set up project templates:**
1. Switch to the "Project Templates" tab
2. Click "Project Settings"
3. Choose your project folder
4. Create project-specific templates or override global ones

### Template Variables

Templates support both built-in and custom variables:

#### Built-in Variables
- `{{FILE_NAME}}` - The name of the file
- `{{PROJECT_NAME}}` - The project name (detected automatically)
- `{{WORKSPACE_NAME}}` - The workspace name
- `{{DATE}}` - Current date (DD/MM/YYYY format)
- `{{YEAR}}` - Current year

#### Custom Variables
You can create your own variables in the template editor:
- `{{AUTHOR}}` - Defaults to your system username
- `{{ORGANIZATION}}` - Your organization name
- `{{SWIFT_VERSION}}` - Swift version being used
- Any custom variables you define

### Example Templates

#### Default Swift Template
```swift
//
//  File name: {{FILE_NAME}}
//  Project name: {{PROJECT_NAME}}
//  Workspace name: {{WORKSPACE_NAME}}
//
//  Created by: {{AUTHOR}} on {{DATE}}
//  Using Swift {{SWIFT_VERSION}}
//  Copyright (c) {{YEAR}} {{ORGANIZATION}}
//
```

#### Minimal Template
```swift
//  {{FILE_NAME}}
//  Created by {{AUTHOR}} on {{DATE}}.
//
```

## Project Structure

The application is organized into several key components:

```
xcode-file-header-template/
├── Models/
│   └── HeaderTemplate.swift          # Data models for templates and variables
├── Services/
│   └── TemplateManager.swift         # Core business logic for template management
├── Views/
│   ├── ContentView.swift            # Main application interface
│   ├── TemplateEditorView.swift     # Template creation and editing
│   ├── ProjectSettingsView.swift    # Project-specific configuration
│   └── SettingsView.swift           # Application preferences
├── Utilities/
│   └── FileProcessorUtility.swift   # File processing and batch operations
└── MenuCommands.swift               # macOS menu integration
```

## Keyboard Shortcuts

- `⌘+T` - New Template
- `⌘+Shift+A` - Apply Template to Files
- `⌘+,` - Preferences

## Requirements

- macOS 15.7 or later
- Xcode 17.0 or later (for building from source)
- Swift 6.0

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is open source and available under the [MIT License](LICENSE).

## Support

If you encounter any issues or have feature requests, please:
1. Check the existing issues on GitHub
2. Create a new issue with detailed information about the problem
3. Include your macOS version and any relevant project details

## Roadmap

- [ ] Xcode extension integration
- [ ] Template marketplace/sharing
- [ ] Support for additional file types (Objective-C, C++, etc.)
- [ ] Integration with version control systems
- [ ] Command-line interface for CI/CD pipelines
- [ ] Template validation and linting

---

**Made with ❤️ for the iOS/macOS developer community**