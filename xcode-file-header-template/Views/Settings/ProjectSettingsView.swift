//
//  File name: ProjectSettingsView.swift
//  Project name: xcode-file-header-template
//  Workspace name: xcode-file-header-template
//
//  Created by: nothing-to-add on 28/10/2025
//  Using Swift 6.0
//  Copyright (c) 2023 nothing-to-add
//

import SwiftUI
import UniformTypeIdentifiers

struct ProjectSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var templateManager: TemplateManager
    @Binding var selectedProjectPath: String
    
    @State private var showingFolderPicker = false
    @State private var projectName = ""
    @State private var organizationName = ""
    @State private var hasExistingMacros = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Project IDETemplateMacros")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Configure project-specific template macros that override global settings")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Project Selection
                GroupBox("Project Selection") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Selected Project:")
                            Text(selectedProjectPath.isEmpty ? "None" : URL(fileURLWithPath: selectedProjectPath).lastPathComponent)
                                .foregroundColor(selectedProjectPath.isEmpty ? .secondary : .primary)
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Button("Choose Project Folder") {
                                showingFolderPicker = true
                            }
                            
                            if !selectedProjectPath.isEmpty {
                                Button("Load Project Macros") {
                                    loadProjectSettings()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        
                        if !selectedProjectPath.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("IDETemplateMacros.plist location:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("\(selectedProjectPath)/IDETemplateMacros.plist")
                                    .font(.system(.caption, design: .monospaced))
                                    .padding(4)
                                    .background(Color(NSColor.controlBackgroundColor))
                                    .cornerRadius(4)
                                    .textSelection(.enabled)
                                
                                HStack {
                                    Image(systemName: hasExistingMacros ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(hasExistingMacros ? .green : .orange)
                                    
                                    Text(hasExistingMacros ? "File exists" : "File does not exist")
                                        .font(.caption)
                                        .foregroundColor(hasExistingMacros ? .green : .orange)
                                }
                            }
                        }
                    }
                }
                
                // Project Configuration
                if !selectedProjectPath.isEmpty {
                    GroupBox("Project Configuration") {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Project Name:")
                                TextField("Enter project name", text: $projectName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            HStack {
                                Text("Organization:")
                                TextField("Enter organization name", text: $organizationName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            HStack {
                                if !hasExistingMacros {
                                    Button("Create IDETemplateMacros.plist") {
                                        createProjectMacros()
                                    }
                                    .buttonStyle(.borderedProminent)
                                } else {
                                    Button("Update Project Macros") {
                                        updateProjectMacros()
                                    }
                                    .buttonStyle(.bordered)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                }
                
                // Information
                GroupBox("About Project IDETemplateMacros") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Project-specific IDETemplateMacros.plist files allow you to:")
                            .fontWeight(.medium)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("• Override global template macros for this project only")
                            Text("• Set project-specific PROJECTNAME and ORGANIZATIONNAME")
                            Text("• Customize file headers per project")
                            Text("• Share project template settings with your team")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                        Divider()
                        
                        Text("The file should be placed in your project's root directory (same level as .xcodeproj file)")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Project Settings")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .fileImporter(
            isPresented: $showingFolderPicker,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    selectedProjectPath = url.path
                    loadProjectSettings()
                }
            case .failure(let error):
                print("Failed to select folder: \(error)")
            }
        }
        .frame(minWidth: 600, minHeight: 500)
        .onAppear {
            if !selectedProjectPath.isEmpty {
                loadProjectSettings()
            }
        }
    }
    
    private func loadProjectSettings() {
        guard !selectedProjectPath.isEmpty else { return }
        
        templateManager.loadProjectMacros(for: selectedProjectPath)
        
        // Extract project name from path
        let projectURL = URL(fileURLWithPath: selectedProjectPath)
        projectName = templateManager.projectMacros["PROJECTNAME"] ?? projectURL.lastPathComponent
        organizationName = templateManager.projectMacros["ORGANIZATIONNAME"] ?? templateManager.globalMacros["ORGANIZATIONNAME"] ?? "Your Organization"
        
        // Check if IDETemplateMacros.plist exists
        hasExistingMacros = templateManager.hasProjectMacros(at: selectedProjectPath)
    }
    
    private func createProjectMacros() {
        guard !selectedProjectPath.isEmpty else { return }
        
        // Update project macros with current values
        templateManager.updateProjectMacro(key: "PROJECTNAME", value: projectName)
        templateManager.updateProjectMacro(key: "ORGANIZATIONNAME", value: organizationName)
        
        templateManager.createProjectMacrosFile()
        hasExistingMacros = true
    }
    
    private func updateProjectMacros() {
        guard !selectedProjectPath.isEmpty else { return }
        
        templateManager.updateProjectMacro(key: "PROJECTNAME", value: projectName)
        templateManager.updateProjectMacro(key: "ORGANIZATIONNAME", value: organizationName)
    }
}

#Preview {
    ProjectSettingsView(
        templateManager: TemplateManager(),
        selectedProjectPath: .constant("")
    )
}
