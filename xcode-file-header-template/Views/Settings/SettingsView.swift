//
//  File name: SettingsView.swift
//  Project name: xcode-file-header-template
//  Workspace name: xcode-file-header-template
//
//  Created by: nothing-to-add on 21/10/2025
//  Using Swift 6.0
//  Copyright (c) 2023 nothing-to-add
//

import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject var templateManager: TemplateManager
    @Environment(\.dismiss) private var dismiss
    @AppStorage("defaultAuthor") private var defaultAuthor = NSFullUserName()
    @AppStorage("defaultOrganization") private var defaultOrganization = "Your Organization"
    @AppStorage("defaultSwiftVersion") private var defaultSwiftVersion = "6.0"
    @AppStorage("autoApplyTemplates") private var autoApplyTemplates = false
    @AppStorage("backupBeforeApply") private var backupBeforeApply = true
    
    var body: some View {
        NavigationView {
            TabView {
                GeneralSettingsView(
                    defaultAuthor: $defaultAuthor,
                    defaultOrganization: $defaultOrganization,
                    defaultSwiftVersion: $defaultSwiftVersion,
                    autoApplyTemplates: $autoApplyTemplates,
                    backupBeforeApply: $backupBeforeApply
                )
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                
                MacroSettingsView()
                    .tabItem {
                        Label("IDETemplateMacros", systemImage: "doc.text")
                    }
                    .environmentObject(templateManager)
                
                AboutView()
                    .tabItem {
                        Label("About", systemImage: "info.circle")
                    }
            }
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .frame(width: 500, height: 400)
    }
}

#Preview {
    SettingsView()
        .environmentObject(TemplateManager())
}
