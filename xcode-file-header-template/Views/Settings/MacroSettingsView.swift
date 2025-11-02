//
//  MacroSettingsView.swift
//  xcode-file-header-template
//
//  Created by maksims.laitans on 03/11/2025.
//

import SwiftUI
import UniformTypeIdentifiers

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

#Preview {
    MacroSettingsView()
}
