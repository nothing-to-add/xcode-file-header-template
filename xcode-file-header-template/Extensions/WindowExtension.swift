//
//  File name: WindowExtension.swift
//  Project name: xcode-file-header-template
//  Workspace name: xcode-file-header-template
//
//  Created by: nothing-to-add on 11/11/2025
//  Using Swift 6.0
//  Copyright (c) 2023 nothing-to-add
//

import SwiftUI
import AppKit

extension NSScreen {
    /// Returns the usable screen size (excluding dock and menu bar)
    static var usableScreenSize: CGSize {
        guard let mainScreen = NSScreen.main else {
            return CGSize(width: 1440, height: 900) // fallback size
        }
        
        let visibleFrame = mainScreen.visibleFrame
        return CGSize(width: visibleFrame.width, height: visibleFrame.height)
    }
    
    /// Returns optimal window size based on screen dimensions
    static func optimalWindowSize(aspectRatio: CGFloat = 1.5) -> CGSize {
        let screenSize = usableScreenSize
        
        // Use 70% of screen size as default
        let maxWidth = screenSize.width * 0.7
        let maxHeight = screenSize.height * 0.7
        
        // Calculate based on aspect ratio (width:height)
        var width = maxWidth
        var height = width / aspectRatio
        
        // If height is too large, adjust based on height
        if height > maxHeight {
            height = maxHeight
            width = height * aspectRatio
        }
        
        return CGSize(width: max(width, 1000), height: max(height, 500))
    }
    
    /// Returns minimum window size based on screen dimensions
    static var minimumWindowSize: CGSize {
        let screenSize = usableScreenSize
        
        // Minimum should be at least 40% of screen or absolute minimums
        let minWidth = max(screenSize.width * 0.4, 1000)
        let minHeight = max(screenSize.height * 0.4, 500)
        
        return CGSize(width: minWidth, height: minHeight)
    }
}

struct WindowSizeModifier: ViewModifier {
    let minSize: CGSize
    let idealSize: CGSize
    
    func body(content: Content) -> some View {
        content
            .frame(
                minWidth: minSize.width,
                idealWidth: idealSize.width,
                minHeight: minSize.height,
                idealHeight: idealSize.height
            )
    }
}

extension View {
    func windowSizing(
        minSize: CGSize = NSScreen.minimumWindowSize,
        idealSize: CGSize = NSScreen.optimalWindowSize()
    ) -> some View {
        self.modifier(WindowSizeModifier(minSize: minSize, idealSize: idealSize))
    }
}
