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
    @State private var showingMacroEditor = false
    @State private var showingProjectSettings = false
    @State private var showingSettings = false
    @State private var editingMacro: IDETemplateMacro?
    @State private var selectedProjectPath: String = ""
    @State private var selectedMacroKey: String? = nil
    
    var body: some View {
        NavigationView {
            // Sidebar
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading) {
                    Text("IDETemplateMacros Manager")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Manage Xcode's IDETemplateMacros.plist files")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Tab Selection
                Picker("Scope", selection: $selectedTab) {
                    Text("Global Macros").tag(0)
                    Text("Project Macros").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Macro List
                List(selection: $selectedMacroKey) {
                    if selectedTab == 0 {
                        globalMacrosSection
                    } else {
                        projectMacrosSection
                    }
                }
                .listStyle(SidebarListStyle())
                
                // Action Buttons
                HStack {
                    Button("Add Macro") {
                        editingMacro = nil
                        showingMacroEditor = true
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
                
                if selectedTab == 1 {
                    // Project Selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Project:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            if selectedProjectPath.isEmpty {
                                Text("No project selected")
                                    .foregroundColor(.secondary)
                            } else {
                                Text(URL(fileURLWithPath: selectedProjectPath).lastPathComponent)
                                    .font(.caption)
                            }
                            
                            Spacer()
                            
                            Button("Select") {
                                showingProjectSettings = true
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .frame(minWidth: 300, maxWidth: 350)
            
            // Main Content
            Group {
                if let selectedKey = selectedMacroKey {
                    let macros = selectedTab == 0 ? templateManager.globalMacros : templateManager.projectMacros
                    if let selectedValue = macros[selectedKey] {
                        SelectedMacroDetailView(
                            key: selectedKey,
                            value: selectedValue,
                            isGlobal: selectedTab == 0,
                            templateManager: templateManager
                        )
                    } else {
                        EmptySelectionView(isGlobal: selectedTab == 0)
                    }
                } else {
                    MacrosOverviewView(
                        macros: selectedTab == 0 ? templateManager.globalMacros : templateManager.projectMacros,
                        isGlobal: selectedTab == 0,
                        templateManager: templateManager
                    )
                }
            }
        }
        .navigationTitle("IDETemplateMacros")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gear")
                }
                .help("Settings")
            }
        }
        .sheet(isPresented: $showingMacroEditor) {
            MacroEditorView(
                macro: editingMacro,
                isGlobal: selectedTab == 0,
                templateManager: templateManager
            )
        }
        .sheet(isPresented: $showingProjectSettings) {
            ProjectSettingsView(
                templateManager: templateManager,
                selectedProjectPath: $selectedProjectPath
            )
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(templateManager)
        }
        .onChange(of: selectedProjectPath) { newPath in
            if !newPath.isEmpty {
                templateManager.loadProjectMacros(for: newPath)
            }
        }
    }
    
    private var globalMacrosSection: some View {
        ForEach(Array(templateManager.globalMacros.keys.sorted()), id: \.self) { key in
            SelectableMacroRow(
                key: key,
                value: templateManager.globalMacros[key] ?? "",
                isBuiltIn: IDETemplateMacro.builtInMacros.contains { $0.key == key },
                isSelected: selectedMacroKey == key
            ) {
                editingMacro = IDETemplateMacro(key: key, value: templateManager.globalMacros[key] ?? "")
                showingMacroEditor = true
            } onDelete: {
                templateManager.deleteGlobalMacro(key: key)
                if selectedMacroKey == key {
                    selectedMacroKey = nil
                }
            }
            .tag(key)
        }
    }
    
    private var projectMacrosSection: some View {
        ForEach(Array(templateManager.projectMacros.keys.sorted()), id: \.self) { key in
            SelectableMacroRow(
                key: key,
                value: templateManager.projectMacros[key] ?? "",
                isBuiltIn: false,
                isSelected: selectedMacroKey == key
            ) {
                editingMacro = IDETemplateMacro(key: key, value: templateManager.projectMacros[key] ?? "")
                showingMacroEditor = true
            } onDelete: {
                templateManager.deleteProjectMacro(key: key)
                if selectedMacroKey == key {
                    selectedMacroKey = nil
                }
            }
            .tag(key)
        }
    }
}

struct SelectableMacroRow: View {
    let key: String
    let value: String
    let isBuiltIn: Bool
    let isSelected: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(key)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    if isBuiltIn {
                        Text("Built-in")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(isSelected ? Color.white.opacity(0.2) : Color.blue.opacity(0.1))
                            .foregroundColor(isSelected ? .white : .blue)
                            .cornerRadius(4)
                    }
                }
                
                Text(key == "FILEHEADER" ? "File Header Template" : String(value.prefix(40)))
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Menu {
                Button("Edit") { onEdit() }
                if !isBuiltIn {
                    Button("Delete", role: .destructive) { onDelete() }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .menuStyle(BorderlessButtonMenuStyle())
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isSelected ? Color.accentColor : Color.clear)
        .cornerRadius(8)
    }
}



struct TemplateSelectionView: View {
    let templates: [FileHeaderTemplate]
    @Binding var selectedIndex: Int
    let isGlobal: Bool
    let templateManager: TemplateManager
    @Environment(\.dismiss) private var dismiss
    @State private var previewContent = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Template List
                List(templates.indices, id: \.self, selection: $selectedIndex) { index in
                    TemplateRowView(
                        template: templates[index],
                        isSelected: selectedIndex == index
                    )
                    .tag(index)
                }
                .listStyle(SidebarListStyle())
                .frame(minWidth: 250, maxWidth: 300)
                
                Divider()
                
                // Preview Area
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Preview: \(templates[selectedIndex].name)")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button("Apply Template") {
                            applyTemplate()
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    
                    ScrollView {
                        Text(previewContent)
                            .font(.system(.body, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    }
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                .frame(minWidth: 400)
            }
        }
        .navigationTitle("Select File Header Template")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .onAppear {
            updatePreview()
        }
        .onChange(of: selectedIndex) { _ in
            updatePreview()
        }
        .frame(minWidth: 700, minHeight: 500)
    }
    
    private func updatePreview() {
        let template = templates[selectedIndex]
        previewContent = template.content.replacingXcodePlaceholders()
    }
    
    private func applyTemplate() {
        let selectedTemplate = templates[selectedIndex]
        
        if isGlobal {
            templateManager.globalMacros["FILEHEADER"] = selectedTemplate.content
            templateManager.saveGlobalMacros()
        } else {
            templateManager.projectMacros["FILEHEADER"] = selectedTemplate.content
            templateManager.saveProjectMacros()
        }
    }
}

struct TemplateRowView: View {
    let template: FileHeaderTemplate
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(template.name)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            
            Text(template.description)
                .font(.caption)
                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
        .background(isSelected ? Color.accentColor : Color.clear)
        .cornerRadius(6)
    }
}

struct MacroDetailRow: View {
    let key: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(key)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if key == "FILEHEADER" {
                    Text("Header Template")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.purple.opacity(0.1))
                        .foregroundColor(.purple)
                        .cornerRadius(4)
                }
            }
            
            Text(value)
                .font(.system(.body, design: .monospaced))
                .padding(8)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
        }
    }
}

struct SelectedMacroDetailView: View {
    let key: String
    let value: String
    let isGlobal: Bool
    let templateManager: TemplateManager
    @State private var showingTemplateSelector = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(key)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Label(isGlobal ? "Global" : "Project", 
                          systemImage: isGlobal ? "globe" : "folder")
                        .foregroundColor(isGlobal ? .blue : .green)
                }
                
                Text(IDETemplateMacro.getDescription(for: key))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Template selector for FILEHEADER
            if key == "FILEHEADER" {
                GroupBox("File Header Templates") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Select Template:")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button("Browse Templates") {
                                showingTemplateSelector = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        
                        // Current template preview
                        ScrollView {
                            Text(templateManager.previewFileHeader())
                                .font(.system(.body, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                        }
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                        .frame(height: 200)
                    }
                    .padding()
                }
            } else {
                // Regular macro value display
                GroupBox("Macro Value") {
                    ScrollView {
                        Text(value)
                            .font(.system(.body, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .textSelection(.enabled)
                    }
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                    .frame(minHeight: 200)
                }
            }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showingTemplateSelector) {
            TemplateSelectionView(
                templates: FileHeaderTemplate.defaultTemplates,
                selectedIndex: .constant(0),
                isGlobal: isGlobal,
                templateManager: templateManager
            )
        }
    }
}

struct MacrosOverviewView: View {
    let macros: [String: String]
    let isGlobal: Bool
    let templateManager: TemplateManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(isGlobal ? "Global" : "Project") IDETemplateMacros")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Label(isGlobal ? "Global" : "Project", 
                          systemImage: isGlobal ? "globe" : "folder")
                        .foregroundColor(isGlobal ? .blue : .green)
                }
                
                Text(isGlobal 
                     ? "~/Library/Developer/Xcode/UserData/IDETemplateMacros.plist"
                     : "<ProjectPath>/IDETemplateMacros.plist")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textSelection(.enabled)
            }
            
            if macros.isEmpty {
                EmptyMacrosView(isGlobal: isGlobal)
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Select a macro from the sidebar to view and edit its details.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    GroupBox("Available Macros (\(macros.count))") {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(Array(macros.keys.sorted()), id: \.self) { key in
                                MacroSummaryCard(key: key, value: macros[key] ?? "")
                            }
                        }
                        .padding()
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

struct MacroSummaryCard: View {
    let key: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(key)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Text(key == "FILEHEADER" ? "File Header Template" : String(value.prefix(60)))
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct EmptySelectionView: View {
    let isGlobal: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Macro Selected")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Select a macro from the sidebar to view its details and edit options.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyMacrosView: View {
    let isGlobal: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: isGlobal ? "doc.text.badge.plus" : "folder.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No \(isGlobal ? "Global" : "Project") Macros")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(isGlobal 
                     ? "Add template macros to customize Xcode's file headers globally"
                     : "Select a project and add project-specific template macros")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
        .environmentObject(TemplateManager())
}
