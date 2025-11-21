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
    @State private var showingProjectSettings = false
    @State private var showingSettings = false
    @State private var editingMacro: IDETemplateMacro?
    @State private var selectedProjectPath: String = ""
    @State private var selectedMacro: IDETemplateMacro? = nil
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            VStack(alignment: .leading, spacing: 20) {
                // Header
                header
                
                // Tab Selection
                tabSelection
                
                // Macro List
                macroList
                
                // Action Buttons
                actionButtons
                
                if selectedTab == 1 {
                    // Project Selector
                    projectSelector
                }
            }
            .navigationSplitViewColumnWidth(350)
        } detail: {
            // Main Content
            mainContent
                .frame(minWidth: 600)
                .navigationTitle("Xcode Template Macros")
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
        }
        .navigationSplitViewStyle(.balanced)
        .onChange(of: selectedProjectPath) { _, newPath in
            if !newPath.isEmpty {
                templateManager.loadProjectMacros(for: newPath)
            }
        }
        // Move all sheet presentations outside of NavigationView scope
        .sheet(item: $editingMacro) { macro in
            MacroEditorView(
                macro: macro,
                isGlobal: selectedTab == 0
            )
            .environmentObject(templateManager)
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingProjectSettings) {
            ProjectSettingsView(
                templateManager: templateManager,
                selectedProjectPath: $selectedProjectPath
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(templateManager)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Xcode Template Macros")
                .font(.title2)
                .fontWeight(.bold)
            Text("Manage IDETemplateMacros.plist files")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
    
    private var tabSelection: some View {
        Picker("Scope", selection: $selectedTab) {
            Text("Global Macros").tag(0)
            Text("Project Macros").tag(1)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }
    
    private var macroList: some View {
        List(selection: $selectedMacro) {
            if selectedTab == 0 {
                globalMacrosSection
            } else {
                projectMacrosSection
            }
        }
        .listStyle(SidebarListStyle())
    }
    
    private var actionButtons: some View {
        HStack {
            Button("Add Macro") {
                editingMacro = IDETemplateMacro.getEmptyMacro(isGlobal: selectedTab == 0)
            }
            .buttonStyle(.bordered)
            
            if selectedTab == 1 {
                Button("Project Settings") {
                    showingProjectSettings = true
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    private var projectSelector: some View {
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
    
    private var mainContent: some View {
        Group {
            if let selectedMacro {
                let macros = selectedTab == 0 ? templateManager.globalMacros : templateManager.projectMacros
                if macros.contains(selectedMacro) {
                    SelectedMacroDetailView(
                        macro: selectedMacro
                    )
                } else {
                    EmptySelectionView(isGlobal: selectedTab == 0)
                }
            } else {
                MacrosOverviewView(isGlobal: selectedTab == 0)
            }
        }
    }
    
    private func macroSection(
        macros: [IDETemplateMacro],
        isGlobal: Bool,
        deleteMacro: @escaping (IDETemplateMacro) -> MacroResult
    ) -> some View {
        ForEach(macros, id: \.id) { macro in
            SelectableMacroRow(
                name: macro.name,
                value: macro.value,
                isBuiltIn: isGlobal && IDETemplateMacro.builtInMacros.contains { $0.name == macro.name },
                isSelected: selectedMacro == macro
            ) {
                editingMacro = macro
            } onDelete: {
                deleteMacro(macro)
                if selectedMacro == macro {
                    selectedMacro = nil
                }
            }
            .tag(macro)
        }
    }
    
    private var globalMacrosSection: some View {
        macroSection(
            macros: templateManager.globalMacros,
            isGlobal: true,
            deleteMacro: templateManager.deleteGlobalMacro
        )
    }
    
    private var projectMacrosSection: some View {
        macroSection(
            macros: templateManager.projectMacros,
            isGlobal: false,
            deleteMacro: templateManager.deleteProjectMacro
        )
    }
}

#Preview {
    ContentView()
        .environmentObject(TemplateManager())
}
