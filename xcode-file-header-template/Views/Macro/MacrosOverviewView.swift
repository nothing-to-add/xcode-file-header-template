//
//  File name: MacrosOverviewView.swift
//  Project name: xcode-file-header-template
//  Workspace name: xcode-file-header-template
//
//  Created by: nothing-to-add on 03/11/2025
//  Using Swift 6.0
//  Copyright (c) 2023 nothing-to-add
//

import SwiftUI

struct MacrosOverviewView: View {
    let isGlobal: Bool
    @EnvironmentObject var templateManager: TemplateManager
    @State private var showingMacroEditor = false
    @State private var selectedMacroKey: String = ""
    @State private var selectedMacroValue: String = ""
    
    private var macros: [IDETemplateMacro] {
        isGlobal ? templateManager.globalMacros : templateManager.projectMacros
    }
    
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
                
                if isGlobal {
                    HStack {
                        Text("~/Library/Developer/Xcode/UserData/IDETemplateMacros.plist")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                        
                        Spacer()
                        
                        if templateManager.hasRealXcodeAccess {
                            Label("Connected", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else {
                            Button("Grant Access") {
                                templateManager.requestXcodeAccessWithUserFriendlyPrompt()
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                    }
                } else {
                    Text("<ProjectPath>/IDETemplateMacros.plist")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textSelection(.enabled)
                }
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
                            ForEach(macros.sorted(by: { $0.name < $1.name}), id: \.self) { macro in
                                MacroSummaryCard(
                                    macro: macro) {
                                        selectedMacroKey = macro.name
                                    selectedMacroValue = macro.value
                                    showingMacroEditor = true
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showingMacroEditor) {
            MacroEditorView(
                macro: IDETemplateMacro(name: selectedMacroKey, value: selectedMacroValue),
                isGlobal: isGlobal
            )
            .environmentObject(templateManager)
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }
}


#Preview {
    let templateManager = TemplateManager()
    // Add some sample data for preview
    templateManager.globalMacros = [
        IDETemplateMacro(name: "FILEBASENAME", value: "MyFile"),
        IDETemplateMacro(name: "PROJECTNAME", value: "xcode-file-header-template"),
        IDETemplateMacro(name: "FULLUSERNAME", value: "nothing-to-add"),
        IDETemplateMacro(name: "DATE", value: "03/11/2025"),
        IDETemplateMacro(name: "YEAR", value: "2025"),
        IDETemplateMacro(name: "ORGANIZATIONNAME", value: "nothing-to-add")
    ]
    
    return MacrosOverviewView(isGlobal: true)
        .environmentObject(templateManager)
}
