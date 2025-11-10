//
//  File name: xcode_file_header_templateApp.swift
//  Project name: xcode-file-header-template
//  Workspace name: xcode-file-header-template
//
//  Created by: nothing-to-add on 21/10/2025
//  Using Swift 6.0
//  Copyright (c) 2023 nothing-to-add
//

import SwiftUI
import AppKit

@main
struct xcode_file_header_templateApp: App {
    @StateObject private var templateManager = TemplateManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(templateManager)
                .windowSizing()
        }
        .windowResizability(.contentSize)
        .defaultSize(NSScreen.optimalWindowSize(aspectRatio: 1.8))
        .commands {
            MenuCommands(templateManager: templateManager)
        }
        
        // Settings window
        Settings {
            SettingsView()
                .environmentObject(templateManager)
        }
    }
}
