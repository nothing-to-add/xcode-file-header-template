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
    
    private var macros: [String: String] {
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
                            ForEach(Array(macros.keys.sorted()), id: \.self) { key in
                                MacroSummaryCard(
                                    key: key,
                                    value: macros[key] ?? ""
                                ) {
                                    selectedMacroKey = key
                                    selectedMacroValue = macros[key] ?? ""
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
                macro: IDETemplateMacro(key: selectedMacroKey, value: selectedMacroValue),
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
        "FILEBASENAME": "MyFile",
        "PROJECTNAME": "xcode-file-header-template",
        "FULLUSERNAME": "nothing-to-add",
        "DATE": "03/11/2025",
        "YEAR": "2025",
        "ORGANIZATIONNAME": "nothing-to-add"
    ]
    
    return MacrosOverviewView(isGlobal: true)
        .environmentObject(templateManager)
}
