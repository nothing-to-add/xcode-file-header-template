//
//  File name: MenuCommands.swift
//  Project name: xcode-file-header-template
//  Workspace name: xcode-file-header-template
//
//  Created by: nothing-to-add on 21/10/2025
//  Using Swift 6.0
//  Copyright (c) 2023 nothing-to-add
//

import SwiftUI

struct MenuCommands: Commands {
    @ObservedObject var templateManager: TemplateManager
    
    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("New Template...") {
                // This would need to be handled by the main view
                NotificationCenter.default.post(name: .showTemplateEditor, object: nil)
            }
            .keyboardShortcut("t", modifiers: [.command])
            
            Divider()
        }
        
        CommandGroup(replacing: .help) {
            Button("Xcode Header Templates Help") {
                if let url = URL(string: "https://github.com/nothing-to-add/xcode-file-header-template") {
                    NSWorkspace.shared.open(url)
                }
            }
        }
        
        CommandMenu("Templates") {
            Button("Manage Global Templates") {
                NotificationCenter.default.post(name: .showGlobalTemplates, object: nil)
            }
            
            Button("Manage Project Templates") {
                NotificationCenter.default.post(name: .showProjectSettings, object: nil)
            }
            
            Divider()
            
            Button("Apply Template to File...") {
                NotificationCenter.default.post(name: .showFileProcessor, object: nil)
            }
            .keyboardShortcut("a", modifiers: [.command, .shift])
            
            Divider()
            
            Menu("Recent Projects") {
                // This would show recent projects
                Text("No recent projects")
                    .disabled(true)
            }
        }
    }
}

extension Notification.Name {
    static let showTemplateEditor = Notification.Name("showTemplateEditor")
    static let showGlobalTemplates = Notification.Name("showGlobalTemplates")
    static let showProjectSettings = Notification.Name("showProjectSettings")
    static let showFileProcessor = Notification.Name("showFileProcessor")
}
