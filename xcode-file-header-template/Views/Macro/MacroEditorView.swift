//
//  File name: MacroEditorView.swift
//  Project name: xcode-file-header-template
//  Workspace name: xcode-file-header-template
//
//  Created by: nothing-to-add on 28/10/2025
//  Using Swift 6.0
//  Copyright (c) 2023 nothing-to-add
//

import SwiftUI

struct MacroEditorView: View {
    let macro: IDETemplateMacro?
    let isGlobal: Bool
    @EnvironmentObject var templateManager: TemplateManager
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var key: String = ""
    @State private var value: String = ""
    @State private var selectedTemplate: FileHeaderTemplate?
    @State private var isEditingExisting: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(isEditingExisting ? "Edit Template Macro" : "Add Template Macro")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(isGlobal ? "Global IDETemplateMacros.plist" : "Project IDETemplateMacros.plist")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Key Field
                GroupBox("Macro Key") {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Enter macro key (e.g., FILEHEADER, ORGANIZATIONNAME)", text: $key)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disabled(isEditingExisting)
                        
                        if key == "FILEHEADER" {
                            Text("This macro defines the file header template that Xcode uses for new files")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                // Template Presets (for FILEHEADER)
                if key == "FILEHEADER" {
                    GroupBox("Template Presets") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Choose a preset template or create custom:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                ForEach(FileHeaderTemplate.defaultTemplates) { template in
                                    Button {
                                        selectedTemplate = template
                                        value = template.content
                                    } label: {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(template.name)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            
                                            Text(template.description)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.leading)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(8)
                                        .background(selectedTemplate?.id == template.id ? Color.accentColor.opacity(0.1) : Color(NSColor.controlBackgroundColor))
                                        .cornerRadius(8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                }
                
                // Value Field
                GroupBox("Macro Value") {
                    VStack(alignment: .leading, spacing: 8) {
                        if key == "FILEHEADER" {
                            Text("File Header Template:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            TextEditor(text: $value)
                                .font(.system(.body, design: .monospaced))
                                .frame(minHeight: 200)
                                .padding(4)
                                .background(Color(NSColor.textBackgroundColor))
                                .cornerRadius(6)
                        } else {
                            TextField("Enter macro value", text: $value)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Template Key Information
                        VStack(alignment: .leading, spacing: 8) {
                            if let templateKey = TemplateKeys(rawValue: key) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("About \(templateKey.displayName):")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                    
                                    Text(templateKey.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(8)
                                .background(Color.blue.opacity(0.05))
                                .cornerRadius(6)
                            }
                            
                            // Xcode Placeholders Help (for FILEHEADER only)
                            if key == "FILEHEADER" {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Available Xcode placeholders:")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                    
                                    ScrollView {
                                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: 2) {
                                            ForEach(TemplateKeys.allCases.filter { $0 != .fileHeader }, id: \.id) { templateKey in
                                                HStack {
                                                    Text("___\(templateKey.rawValue)___")
                                                        .font(.system(.caption2, design: .monospaced))
                                                        .foregroundColor(.blue)
                                                    
                                                    Text("- \(templateKey.displayName)")
                                                        .font(.caption2)
                                                        .foregroundColor(.secondary)
                                                    
                                                    Spacer()
                                                }
                                            }
                                        }
                                    }
                                    .frame(maxHeight: 150)
                                }
                                .padding(8)
                                .background(Color.green.opacity(0.05))
                                .cornerRadius(6)
                            }
                        }
                    }
                }
                
                // Preview
                if key == "FILEHEADER" && !value.isEmpty {
                    GroupBox("Preview") {
                        ScrollView {
                            Text(value.replacingXcodePlaceholders())
                                .font(.system(.body, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                        }
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                        .frame(height: 150)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(isEditingExisting ? "Edit Macro" : "Add Macro")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveMacro()
                    dismiss()
                }
                .disabled(key.isEmpty || value.isEmpty)
            }
        }
        .onAppear {
            if let macro {
                key = macro.key
                value = macro.value
                isEditingExisting = true
            }
        }
    }
    
    private func saveMacro() {
        if isGlobal {
            templateManager.updateGlobalMacro(key: key, value: value)
        } else {
            templateManager.updateProjectMacro(key: key, value: value)
        }
    }
}

#Preview {
    MacroEditorView(
        macro: nil,
        isGlobal: true
    )
    .environmentObject(TemplateManager())
}
