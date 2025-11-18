//
//  File name: SelectedMacroDetailView.swift
//  Project name: xcode-file-header-template
//  Workspace name: xcode-file-header-template
//
//  Created by: nothing-to-add on 03/11/2025
//  Using Swift 6.0
//  Copyright (c) 2023 nothing-to-add
//

import SwiftUI

struct SelectedMacroDetailView: View {
    let macro: IDETemplateMacro
    @EnvironmentObject var templateManager: TemplateManager
    @State private var showingTemplateSelector = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(macro.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Label(macro.isGlobal ? "Global" : "Project",
                          systemImage: macro.isGlobal ? "globe" : "folder")
                    .foregroundColor(macro.isGlobal ? .blue : .green)
                }
                
                Text(IDETemplateMacro.getDescription(for: macro.name))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Template selector for FILEHEADER
            if macro.name == "FILEHEADER" {
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
                        Text(macro.value)
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
                isGlobal: macro.isGlobal
            )
        }
    }
}

#Preview {
    let value = """
//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  ___COPYRIGHT___
//
"""
    let macro = IDETemplateMacro(name: "FILEHEADER", value: value, isGlobal: true)
    var templateManager = TemplateManager()
//    templateManager.globalMacros.first(where: { $0.name == "FILEHEADER"}) = macro
    
    SelectedMacroDetailView(
        macro: macro
    )
    .environmentObject(templateManager)
}
