# Window Sizing and Aspect Ratio Features

This document describes the window sizing and aspect ratio features implemented in the Xcode Template Macros Manager.

## Features Implemented

### 1. Screen-Aware Window Sizing
- **WindowExtension.swift**: Added utilities to detect screen size and calculate optimal window dimensions
- **Dynamic sizing**: Window sizes adapt to your screen resolution
- **Minimum constraints**: Ensures the app is never too small to be functional

### 2. Aspect Ratio Management
- **Configurable aspect ratio**: Default 1.4:1 (width:height) ratio for optimal layout
- **Screen percentage**: Uses 70% of available screen space by default
- **Fallback sizes**: Provides sensible defaults when screen detection fails

### 3. Responsive Layout
- **Compact mode**: Adjusts layout for smaller windows (< 1200px width)
- **Dynamic sidebar**: Sidebar width adjusts based on available space
- **Button layout**: Buttons stack vertically in compact mode for better usability

### 4. Window Configuration
- **App level**: `windowResizability(.contentSize)` allows window to be resized
- **Content level**: `.windowSizing()` modifier applies intelligent sizing
- **Default size**: Calculated optimal size based on screen dimensions

## How It Works

### Screen Detection
```swift
extension NSScreen {
    static var usableScreenSize: CGSize {
        // Returns screen size excluding dock and menu bar
    }
    
    static func optimalWindowSize(aspectRatio: CGFloat = 1.5) -> CGSize {
        // Calculates optimal window size based on screen and aspect ratio
    }
}
```

### Window Sizing Modifier
```swift
.windowSizing(
    minSize: NSScreen.minimumWindowSize,     // 40% of screen or 1000x700 minimum
    idealSize: NSScreen.optimalWindowSize()   // 70% of screen with 1.4 aspect ratio
)
```

### Responsive ContentView
- **Window size tracking**: `GeometryReader` monitors window size changes
- **Compact detection**: Automatically switches layout when width < 1200px
- **Dynamic measurements**: Sidebar and content areas adjust proportionally

## Configuration Options

### Aspect Ratio
Change the default aspect ratio in `xcode_file_header_templateApp.swift`:
```swift
.defaultSize(NSScreen.optimalWindowSize(aspectRatio: 1.6)) // Wider window
```

### Minimum Size
Adjust minimum size constraints in `WindowExtension.swift`:
```swift
static var minimumWindowSize: CGSize {
    let screenSize = usableScreenSize
    let minWidth = max(screenSize.width * 0.3, 800)  // Smaller minimum
    let minHeight = max(screenSize.height * 0.3, 600) // Smaller minimum
    return CGSize(width: minWidth, height: minHeight)
}
```

### Screen Percentage
Change how much of the screen the app uses by default:
```swift
// In optimalWindowSize method
let maxWidth = screenSize.width * 0.8  // Use 80% instead of 70%
let maxHeight = screenSize.height * 0.8
```

## Benefits

1. **Adaptive to different screen sizes**: Works well on laptops, external monitors, and ultra-wide displays
2. **Consistent user experience**: Maintains usable proportions regardless of screen size
3. **Responsive design**: Layout adapts to window size changes automatically
4. **Professional appearance**: Proper window sizing creates a more polished app experience

## Usage Examples

### Large Screen (2560x1440)
- Optimal size: ~1792x1280 (70% of 2560x1440 with 1.4 ratio)
- Minimum size: ~1024x576 (40% of screen)
- Compact mode: Activated when window width < 1200px

### Laptop Screen (1440x900)
- Optimal size: ~1008x720 (70% of 1440x900 with 1.4 ratio)
- Minimum size: ~800x600 (falls back to absolute minimums)
- Compact mode: Often activated due to smaller screen

### Ultra-wide Screen (3440x1440)
- Optimal size: ~2408x1008 (70% of 3440x1440 with 1.4 ratio, height-limited)
- Uses maximum height available while maintaining aspect ratio
- Wide screen real estate utilized efficiently

The implementation ensures your Xcode Template Macros Manager app looks and functions optimally across all Mac configurations!
