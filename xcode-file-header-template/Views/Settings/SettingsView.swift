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

struct MacroSettingsView: View {
    @EnvironmentObject var templateManager: TemplateManager
    @State private var showingResetAlert = false
    @State private var globalMacros: [String: Any] = [:]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            GroupBox("IDETemplateMacros Location") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Global Macros:")
                        Text("\(templateManager.globalMacros.count)")
                            .foregroundColor(.blue)
                        Spacer()
                        Button("Open Xcode UserData Folder") {
                            openXcodeUserDataFolder()
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Text("Global: ~/Library/Developer/Xcode/UserData/IDETemplateMacros.plist")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Project: <ProjectPath>/IDETemplateMacros.plist")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            GroupBox("Actions") {
                VStack(spacing: 12) {
                    HStack {
                        Button("Export Global Macros...") {
                            exportGlobalMacros()
                        }
                        
                        Button("Import Global Macros...") {
                            importGlobalMacros()
                        }
                        
                        Spacer()
                        
                        Button("Reset to Xcode Defaults") {
                            showingResetAlert = true
                        }
                        .foregroundColor(.red)
                    }
                    
                    Text("Export/Import allows you to backup and share IDETemplateMacros between machines")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            loadGlobalMacros()
        }
        .alert("Reset IDETemplateMacros", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetToDefaults()
            }
        } message: {
            Text("This will delete all global IDETemplateMacros and restore Xcode defaults. This action cannot be undone.")
        }
    }
    
    private func loadGlobalMacros() {
        templateManager.loadGlobalMacros()
        globalMacros = templateManager.globalMacros
    }
    
    private func openXcodeUserDataFolder() {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let xcodeUserData = homeDir.appendingPathComponent("Library/Developer/Xcode/UserData")
        NSWorkspace.shared.open(xcodeUserData)
    }
    
    private func exportGlobalMacros() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType(filenameExtension: "plist")!]
        panel.nameFieldStringValue = "IDETemplateMacros.plist"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                do {
                    let data = try PropertyListSerialization.data(fromPropertyList: templateManager.globalMacros, format: .xml, options: 0)
                    try data.write(to: url)
                } catch {
                    print("Export failed: \(error)")
                }
            }
        }
    }
    
    private func importGlobalMacros() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType(filenameExtension: "plist")!]
        panel.allowsMultipleSelection = false
        
        panel.begin { response in
            if response == .OK, let url = panel.urls.first {
                do {
                    let data = try Data(contentsOf: url)
                    guard let importedMacros = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
                        print("Invalid plist format")
                        return
                    }
                    
                    templateManager.globalMacros = importedMacros.compactMapValues { $0 as? String }
                    templateManager.saveGlobalMacros()
                    loadGlobalMacros() // Refresh display
                } catch {
                    print("Import failed: \(error)")
                }
            }
        }
    }
    
    private func resetToDefaults() {
        // Remove the global IDETemplateMacros.plist to restore Xcode defaults
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let macrosURL = homeDir.appendingPathComponent("Library/Developer/Xcode/UserData/IDETemplateMacros.plist")
        
        do {
            if FileManager.default.fileExists(atPath: macrosURL.path) {
                try FileManager.default.removeItem(at: macrosURL)
            }
            loadGlobalMacros() // Refresh display
        } catch {
            print("Failed to reset: \(error)")
        }
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
