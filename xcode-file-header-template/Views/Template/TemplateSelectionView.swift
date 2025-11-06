//
//  File name: TemplateSelectionView.swift
//  Project name: xcode-file-header-template
//  Workspace name: xcode-file-header-template
//
//  Created by: nothing-to-add on 03/11/2025
//  Using Swift 6.0
//  Copyright (c) 2023 nothing-to-add
//

import SwiftUI

struct TemplateSelectionView: View {
    let templates: [FileHeaderTemplate]
    @Binding var selectedIndex: Int
    let isGlobal: Bool
    @EnvironmentObject var templateManager: TemplateManager
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
        .onChange(of: selectedIndex) {
            updatePreview()
        }
        .frame(minWidth: 700, minHeight: 500)
    }
    
    private func updatePreview() {
        let template = templates[selectedIndex]
        let resolvedMacros = templateManager.resolveAllMacros()
        
        previewContent = template.content.replacingXcodePlaceholders(
            filename: "ExampleFile.swift",
            projectName: resolvedMacros["PROJECTNAME"] ?? "MyProject",
            fullUserName: resolvedMacros["FULLUSERNAME"] ?? NSFullUserName(),
            organizationName: resolvedMacros["ORGANIZATIONNAME"] ?? "Your Organization",
            copyright: resolvedMacros["COPYRIGHT"]
        )
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

#Preview {
    TemplateSelectionView(
        templates: FileHeaderTemplate.defaultTemplates,
        selectedIndex: .constant(0),
        isGlobal: true
    )
    .environmentObject(TemplateManager())
}
