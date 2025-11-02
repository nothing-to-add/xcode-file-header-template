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

#Preview {
    SelectedMacroDetailView(
        key: "FILEHEADER",
        value: """
//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  ___COPYRIGHT___
//
""",
        isGlobal: true,
        templateManager: TemplateManager()
    )
}
