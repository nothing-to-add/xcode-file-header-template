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
                    if macros[selectedKey] != nil {
                        SelectedMacroDetailView(
                            key: selectedKey,
                            isGlobal: selectedTab == 0
                        )
                    } else {
                        EmptySelectionView(isGlobal: selectedTab == 0)
                    }
                } else {
                    MacrosOverviewView(isGlobal: selectedTab == 0)
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
                isGlobal: selectedTab == 0
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

#Preview {
    ContentView()
        .environmentObject(TemplateManager())
}
