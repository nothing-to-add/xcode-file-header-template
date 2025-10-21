//
//  File name: TemplateEditorView.swift
//  Project name: xcode-file-header-template
//  Workspace name: xcode-file-header-template
//
//  Created by: nothing-to-add on 21/10/2025
//  Using Swift 6.0
//  Copyright (c) 2023 nothing-to-add
//

import SwiftUI

struct TemplateEditorView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let template: HeaderTemplate?
    let templateManager: TemplateManager
    let isGlobal: Bool
    
    @State private var name: String = ""
    @State private var content: String = ""
    @State private var fileExtensions: String = ""
    @State private var variables: [TemplateVariable] = []
    @State private var showingVariableEditor = false
    @State private var editingVariable: TemplateVariable?
    
    private var isEditing: Bool { template != nil }
    
    init(template: HeaderTemplate?, templateManager: TemplateManager, isGlobal: Bool) {
        self.template = template
        self.templateManager = templateManager
        self.isGlobal = isGlobal
        
        if let template = template {
            _name = State(initialValue: template.name)
            _content = State(initialValue: template.content)
            _fileExtensions = State(initialValue: template.fileExtensions.joined(separator: ", "))
            _variables = State(initialValue: template.variables)
        } else {
            _variables = State(initialValue: TemplateVariable.defaultVariables)
            _content = State(initialValue: """
            //
            //  File name: {{FILE_NAME}}
            //  Project name: {{PROJECT_NAME}}
            //  Workspace name: {{WORKSPACE_NAME}}
            //
            //  Created by: {{AUTHOR}} on {{DATE}}
            //  Using Swift {{SWIFT_VERSION}}
            //  Copyright (c) {{YEAR}} {{ORGANIZATION}}
            //
            """)
            _fileExtensions = State(initialValue: "swift")
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Information
                Section("Template Information") {
                    TextField("Template Name", text: $name)
                    
                    TextField("File Extensions (comma separated)", text: $fileExtensions)
                        .help("Extensions this template applies to, e.g., swift, h, m")
                }
                
                // Variables Section
                Section("Template Variables") {
                    ForEach(variables) { variable in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("{{{\(variable.name.uppercased())}}}")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.blue)
                                
                                Text(variable.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(variable.value)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                            
                            Button("Edit") {
                                editingVariable = variable
                                showingVariableEditor = true
                            }
                            .buttonStyle(.borderless)
                        }
                        .padding(.vertical, 2)
                    }
                    
                    Button("Add Variable") {
                        editingVariable = nil
                        showingVariableEditor = true
                    }
                }
                
                // Template Content
                Section("Template Content") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Available Variables:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 4) {
                            ForEach(allAvailableVariables, id: \.self) { variable in
                                Text("{{{\(variable)}}}")
                                    .font(.caption)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(4)
                                    .onTapGesture {
                                        insertVariable(variable)
                                    }
                            }
                        }
                        
                        TextEditor(text: $content)
                            .font(.system(.body, design: .monospaced))
                            .frame(minHeight: 200)
                            .border(Color.gray.opacity(0.3))
                    }
                }
                
                // Preview Section
                Section("Preview") {
                    Text(generatePreview())
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                }
            }
            .navigationTitle(isEditing ? "Edit Template" : "New Template")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTemplate()
                    }
                    .disabled(name.isEmpty || content.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showingVariableEditor) {
            VariableEditorView(
                variable: editingVariable,
                variables: $variables
            )
        }
        .frame(minWidth: 600, minHeight: 500)
    }
    
    private var allAvailableVariables: [String] {
        let builtInVariables = ["FILE_NAME", "PROJECT_NAME", "WORKSPACE_NAME", "DATE", "YEAR"]
        let customVariables = variables.map { $0.name.uppercased() }
        return builtInVariables + customVariables
    }
    
    private func insertVariable(_ variableName: String) {
        let placeholder = "{{{\(variableName)}}}"
        content += placeholder
    }
    
    private func generatePreview() -> String {
        let extensionArray = fileExtensions.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let previewTemplate = HeaderTemplate(
            name: name.isEmpty ? "Preview" : name,
            content: content,
            isGlobal: isGlobal,
            fileExtensions: extensionArray
        )
        
        // Update variables
        var updatedTemplate = previewTemplate
        updatedTemplate.variables = variables
        
        return updatedTemplate.generateHeader(
            for: "/Example/Project/ExampleFile.\(extensionArray.first ?? "swift")",
            projectName: "Example Project",
            workspaceName: "Example Workspace"
        )
    }
    
    private func saveTemplate() {
        let extensionArray = fileExtensions.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        if let existingTemplate = template {
            // Update existing template
            var updatedTemplate = existingTemplate
            updatedTemplate.name = name
            updatedTemplate.content = content
            updatedTemplate.fileExtensions = extensionArray
            updatedTemplate.variables = variables
            
            if isGlobal {
                templateManager.updateGlobalTemplate(updatedTemplate)
            } else {
                templateManager.updateProjectTemplate(updatedTemplate)
            }
        } else {
            // Create new template
            var newTemplate = HeaderTemplate(
                name: name,
                content: content,
                isGlobal: isGlobal,
                fileExtensions: extensionArray
            )
            newTemplate.variables = variables
            
            if isGlobal {
                templateManager.addGlobalTemplate(newTemplate)
            } else {
                templateManager.addProjectTemplate(newTemplate)
            }
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct VariableEditorView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let variable: TemplateVariable?
    @Binding var variables: [TemplateVariable]
    
    @State private var name: String = ""
    @State private var value: String = ""
    @State private var description: String = ""
    
    private var isEditing: Bool { variable != nil }
    
    init(variable: TemplateVariable?, variables: Binding<[TemplateVariable]>) {
        self.variable = variable
        self._variables = variables
        
        if let variable = variable {
            _name = State(initialValue: variable.name)
            _value = State(initialValue: variable.value)
            _description = State(initialValue: variable.description)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Variable Information") {
                    TextField("Variable Name", text: $name)
                        .help("Used as {{NAME}} in templates")
                    
                    TextField("Default Value", text: $value)
                    
                    TextField("Description", text: $description)
                        .help("Help text for this variable")
                }
                
                Section("Preview") {
                    HStack {
                        Text("Template placeholder:")
                        Text("{{{\(name.uppercased())}}}")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.blue)
                    }
                    
                    HStack {
                        Text("Will be replaced with:")
                        Text(value)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Variable" : "New Variable")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveVariable()
                    }
                    .disabled(name.isEmpty || value.isEmpty)
                }
            }
        }
        .frame(width: 400, height: 300)
    }
    
    private func saveVariable() {
        let newVariable = TemplateVariable(name: name, value: value, description: description)
        
        if let existingVariable = variable {
            if let index = variables.firstIndex(where: { $0.id == existingVariable.id }) {
                variables[index] = newVariable
            }
        } else {
            variables.append(newVariable)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    TemplateEditorView(template: nil, templateManager: TemplateManager(), isGlobal: true)
}
