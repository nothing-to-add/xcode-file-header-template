//
//  File name: ContentView.swift
//  Project name: xcode-file-header-template
//  Workspace name: xcode-file-header-template
//
//  Created by: nothing-to-add on 21/10/2025
//  Using Swift 6.0
//  Copyright (c) 2023 nothing-to-add
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var templateManager: TemplateManager
    @State private var selectedTab = 0
    @State private var showingTemplateEditor = false
    @State private var showingProjectSettings = false
    @State private var editingTemplate: HeaderTemplate?
    
    var body: some View {
        NavigationView {
            // Sidebar
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading) {
                    Text("Xcode Header Templates")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Manage file header templates for Xcode projects")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Tab Selection
                Picker("Template Type", selection: $selectedTab) {
                    Text("Global Templates").tag(0)
                    Text("Project Templates").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Template List
                List {
                    if selectedTab == 0 {
                        globalTemplatesSection
                    } else {
                        projectTemplatesSection
                    }
                }
                .listStyle(SidebarListStyle())
                
                // Action Buttons
                HStack {
                    Button("New Template") {
                        editingTemplate = nil
                        showingTemplateEditor = true
                    }
                    .buttonStyle(.bordered)
                    
                    if selectedTab == 1 {
                        Button("Project Settings") {
                            showingProjectSettings = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.horizontal)
            }
            .frame(minWidth: 300, maxWidth: 350)
            
            // Main Content
            Group {
                if selectedTab == 0, let template = templateManager.selectedGlobalTemplate {
                    TemplatePreviewView(template: template, templateManager: templateManager)
                } else if selectedTab == 1, let template = templateManager.selectedProjectTemplate {
                    TemplatePreviewView(template: template, templateManager: templateManager)
                } else {
                    EmptyStateView(isProjectTab: selectedTab == 1)
                }
            }
        }
        .navigationTitle("Header Templates")
        .sheet(isPresented: $showingTemplateEditor) {
            TemplateEditorView(
                template: editingTemplate,
                templateManager: templateManager,
                isGlobal: selectedTab == 0
            )
        }
        .sheet(isPresented: $showingProjectSettings) {
            ProjectSettingsView(templateManager: templateManager)
        }
    }
    
    private var globalTemplatesSection: some View {
        ForEach(templateManager.globalTemplates) { template in
            TemplateRow(
                template: template,
                isSelected: templateManager.selectedGlobalTemplate?.id == template.id
            ) {
                templateManager.selectedGlobalTemplate = template
            } onEdit: {
                editingTemplate = template
                showingTemplateEditor = true
            } onDelete: {
                templateManager.deleteGlobalTemplate(template)
            }
        }
    }
    
    private var projectTemplatesSection: some View {
        ForEach(templateManager.projectTemplates) { template in
            TemplateRow(
                template: template,
                isSelected: templateManager.selectedProjectTemplate?.id == template.id
            ) {
                templateManager.selectedProjectTemplate = template
            } onEdit: {
                editingTemplate = template
                showingTemplateEditor = true
            } onDelete: {
                templateManager.deleteProjectTemplate(template)
            }
        }
    }
}

struct TemplateRow: View {
    let template: HeaderTemplate
    let isSelected: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(template.name)
                    .font(.headline)
                    .foregroundColor(isSelected ? .primary : .secondary)
                
                Text(template.fileExtensions.map { ".\($0)" }.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !template.isGlobal, let projectPath = template.projectPath {
                    Text(URL(fileURLWithPath: projectPath).lastPathComponent)
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            Menu {
                Button("Edit") { onEdit() }
                Button("Delete", role: .destructive) { onDelete() }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.secondary)
            }
            .menuStyle(BorderlessButtonMenuStyle())
        }
        .padding(.vertical, 4)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(8)
        .onTapGesture { onSelect() }
    }
}

struct EmptyStateView: View {
    let isProjectTab: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: isProjectTab ? "folder.badge.plus" : "doc.text.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(isProjectTab ? "No Project Templates" : "No Templates Selected")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(isProjectTab 
                     ? "Select a project folder to create project-specific templates"
                     : "Select a template from the sidebar to preview and edit")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TemplatePreviewView: View {
    let template: HeaderTemplate
    let templateManager: TemplateManager
    @State private var previewFilePath = "/Example/Project/ExampleFile.swift"
    @State private var previewProjectName = "Example Project"
    @State private var previewWorkspaceName = "Example Workspace"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(template.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    if template.isGlobal {
                        Label("Global", systemImage: "globe")
                            .foregroundColor(.blue)
                    } else {
                        Label("Project", systemImage: "folder")
                            .foregroundColor(.green)
                    }
                }
                
                Text("File extensions: \(template.fileExtensions.map { ".\($0)" }.joined(separator: ", "))")
                    .foregroundColor(.secondary)
            }
            
            // Preview Configuration
            GroupBox("Preview Configuration") {
                VStack(spacing: 12) {
                    HStack {
                        Text("File Path:")
                        TextField("File path", text: $previewFilePath)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack {
                        Text("Project Name:")
                        TextField("Project name", text: $previewProjectName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack {
                        Text("Workspace:")
                        TextField("Workspace name", text: $previewWorkspaceName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
            }
            
            // Preview Output
            GroupBox("Preview Output") {
                ScrollView {
                    Text(template.generateHeader(
                        for: previewFilePath,
                        projectName: previewProjectName,
                        workspaceName: previewWorkspaceName
                    ))
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(TemplateManager())
}
