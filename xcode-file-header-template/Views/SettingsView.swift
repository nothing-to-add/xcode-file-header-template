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
    @AppStorage("defaultAuthor") private var defaultAuthor = NSFullUserName()
    @AppStorage("defaultOrganization") private var defaultOrganization = "Your Organization"
    @AppStorage("defaultSwiftVersion") private var defaultSwiftVersion = "6.0"
    @AppStorage("autoApplyTemplates") private var autoApplyTemplates = false
    @AppStorage("backupBeforeApply") private var backupBeforeApply = true
    
    var body: some View {
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
            
            TemplateSettingsView()
                .tabItem {
                    Label("Templates", systemImage: "doc.text")
                }
                .environmentObject(templateManager)
            
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 500, height: 400)
    }
}

struct GeneralSettingsView: View {
    @Binding var defaultAuthor: String
    @Binding var defaultOrganization: String
    @Binding var defaultSwiftVersion: String
    @Binding var autoApplyTemplates: Bool
    @Binding var backupBeforeApply: Bool
    
    var body: some View {
        Form {
            Section("Default Values") {
                HStack {
                    Text("Author:")
                    TextField("Author name", text: $defaultAuthor)
                }
                
                HStack {
                    Text("Organization:")
                    TextField("Organization name", text: $defaultOrganization)
                }
                
                HStack {
                    Text("Swift Version:")
                    TextField("Swift version", text: $defaultSwiftVersion)
                }
            }
            
            Section("Behavior") {
                Toggle("Auto-apply templates to new files", isOn: $autoApplyTemplates)
                    .help("Automatically apply templates when creating new files")
                
                Toggle("Create backup before applying templates", isOn: $backupBeforeApply)
                    .help("Create .backup files before modifying existing files")
            }
        }
        .padding()
    }
}

struct TemplateSettingsView: View {
    @EnvironmentObject var templateManager: TemplateManager
    @State private var showingResetAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            GroupBox("Template Storage") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Global Templates:")
                        Text("\(templateManager.globalTemplates.count)")
                            .foregroundColor(.blue)
                        Spacer()
                        Button("Open Folder") {
                            openGlobalTemplatesFolder()
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Text("Stored in: ~/Library/Application Support/XcodeFileHeaderTemplate/")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            GroupBox("Actions") {
                VStack(spacing: 12) {
                    HStack {
                        Button("Export Templates...") {
                            exportTemplates()
                        }
                        
                        Button("Import Templates...") {
                            importTemplates()
                        }
                        
                        Spacer()
                        
                        Button("Reset to Defaults") {
                            showingResetAlert = true
                        }
                        .foregroundColor(.red)
                    }
                    
                    Text("Export/Import allows you to share templates between machines or create backups")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .alert("Reset Templates", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetToDefaults()
            }
        } message: {
            Text("This will delete all custom templates and restore the default ones. This action cannot be undone.")
        }
    }
    
    private func openGlobalTemplatesFolder() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("XcodeFileHeaderTemplate")
        NSWorkspace.shared.open(appFolder)
    }
    
    private func exportTemplates() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "HeaderTemplates.json"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                do {
                    let data = try JSONEncoder().encode(templateManager.globalTemplates)
                    try data.write(to: url)
                } catch {
                    print("Export failed: \(error)")
                }
            }
        }
    }
    
    private func importTemplates() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        
        panel.begin { response in
            if response == .OK, let url = panel.urls.first {
                do {
                    let data = try Data(contentsOf: url)
                    let importedTemplates = try JSONDecoder().decode([HeaderTemplate].self, from: data)
                    
                    for template in importedTemplates {
                        templateManager.addGlobalTemplate(template)
                    }
                } catch {
                    print("Import failed: \(error)")
                }
            }
        }
    }
    
    private func resetToDefaults() {
        templateManager.globalTemplates = [
            HeaderTemplate.defaultSwiftTemplate,
            HeaderTemplate.minimalTemplate
        ]
        templateManager.selectedGlobalTemplate = templateManager.globalTemplates.first
        templateManager.saveGlobalTemplates()
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.badge.plus")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)
            
            VStack(spacing: 8) {
                Text("Xcode File Header Template")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Version 1.0.0")
                    .foregroundColor(.secondary)
                
                Text("A macOS application for managing Xcode file header templates")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 8) {
                Link("View on GitHub", destination: URL(string: "https://github.com/nothing-to-add/xcode-file-header-template")!)
                
                Text("Copyright © 2023 nothing-to-add")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    SettingsView()
        .environmentObject(TemplateManager())
}
