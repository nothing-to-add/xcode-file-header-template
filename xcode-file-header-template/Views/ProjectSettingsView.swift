//
//  File name: ProjectSettingsView.swift
//  Project name: xcode-file-header-template
//  Workspace name: xcode-file-header-template
//
//  Created by: nothing-to-add on 21/10/2025
//  Using Swift 6.0
//  Copyright (c) 2023 nothing-to-add
//

import SwiftUI
import UniformTypeIdentifiers

struct ProjectSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var templateManager: TemplateManager
    
    @State private var selectedProjectPath: String = ""
    @State private var showingFolderPicker = false
    @State private var showingFileProcessor = false
    @State private var projectFiles: [ProjectFile] = []
    @State private var isLoadingFiles = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Project Selection
                GroupBox("Project Selection") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Selected Project:")
                            Text(selectedProjectPath.isEmpty ? "None" : URL(fileURLWithPath: selectedProjectPath).lastPathComponent)
                                .foregroundColor(selectedProjectPath.isEmpty ? .secondary : .primary)
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Button("Choose Project Folder") {
                                showingFolderPicker = true
                            }
                            
                            if !selectedProjectPath.isEmpty {
                                Button("Load Templates") {
                                    templateManager.loadProjectTemplates(for: selectedProjectPath)
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        
                        if !templateManager.currentProjectPath.isEmpty {
                            Text("Current: \(URL(fileURLWithPath: templateManager.currentProjectPath).lastPathComponent)")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                // Project Files Processing
                if !templateManager.currentProjectPath.isEmpty {
                    GroupBox("Project Files") {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Button("Scan Project Files") {
                                    scanProjectFiles()
                                }
                                
                                if !projectFiles.isEmpty {
                                    Button("Apply Templates to Files") {
                                        showingFileProcessor = true
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                                
                                Spacer()
                                
                                if isLoadingFiles {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                }
                            }
                            
                            if !projectFiles.isEmpty {
                                Text("\(projectFiles.count) files found")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                ScrollView {
                                    LazyVStack(alignment: .leading, spacing: 4) {
                                        ForEach(projectFiles) { file in
                                            ProjectFileRow(file: file)
                                        }
                                    }
                                }
                                .frame(maxHeight: 200)
                            }
                        }
                    }
                }
                
                // Template Status
                if !templateManager.currentProjectPath.isEmpty {
                    GroupBox("Template Status") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Project Templates:")
                                Text("\(templateManager.projectTemplates.count)")
                                    .foregroundColor(.blue)
                                    .fontWeight(.medium)
                            }
                            
                            HStack {
                                Text("Global Templates:")
                                Text("\(templateManager.globalTemplates.count)")
                                    .foregroundColor(.green)
                                    .fontWeight(.medium)
                            }
                            
                            if let selectedTemplate = templateManager.selectedProjectTemplate {
                                HStack {
                                    Text("Selected:")
                                    Text(selectedTemplate.name)
                                        .foregroundColor(.primary)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Project Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $showingFolderPicker,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    selectedProjectPath = url.path
                }
            case .failure(let error):
                print("Failed to select folder: \(error)")
            }
        }
        .sheet(isPresented: $showingFileProcessor) {
            FileProcessorView(
                projectFiles: projectFiles,
                templateManager: templateManager
            )
        }
        .frame(minWidth: 500, minHeight: 400)
        .onAppear {
            if !templateManager.currentProjectPath.isEmpty {
                selectedProjectPath = templateManager.currentProjectPath
                scanProjectFiles()
            }
        }
    }
    
    private func scanProjectFiles() {
        guard !templateManager.currentProjectPath.isEmpty else { return }
        
        isLoadingFiles = true
        projectFiles = []
        
        DispatchQueue.global(qos: .userInitiated).async {
            let files = scanDirectory(templateManager.currentProjectPath)
            
            DispatchQueue.main.async {
                self.projectFiles = files
                self.isLoadingFiles = false
            }
        }
    }
    
    private func scanDirectory(_ path: String) -> [ProjectFile] {
        var files: [ProjectFile] = []
        let fileManager = FileManager.default
        
        guard let enumerator = fileManager.enumerator(atPath: path) else { return files }
        
        while let file = enumerator.nextObject() as? String {
            let fullPath = URL(fileURLWithPath: path).appendingPathComponent(file).path
            let fileExtension = URL(fileURLWithPath: file).pathExtension
            
            // Skip certain directories and files
            if file.contains(".xcodeproj/") || 
               file.contains(".git/") ||
               file.contains("Pods/") ||
               file.contains("DerivedData/") ||
               file.hasPrefix(".") {
                continue
            }
            
            // Only include source files
            let supportedExtensions = ["swift", "h", "m", "mm", "cpp", "c", "hpp"]
            if supportedExtensions.contains(fileExtension) {
                let projectFile = ProjectFile(
                    path: fullPath,
                    name: URL(fileURLWithPath: file).lastPathComponent,
                    fileExtension: fileExtension,
                    hasHeader: checkIfFileHasHeader(fullPath)
                )
                files.append(projectFile)
            }
        }
        
        return files.sorted { $0.name < $1.name }
    }
    
    private func checkIfFileHasHeader(_ filePath: String) -> Bool {
        do {
            let content = try String(contentsOfFile: filePath)
            let lines = content.components(separatedBy: .newlines)
            
            // Check first few lines for comment patterns
            for line in lines.prefix(10) {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.hasPrefix("//") && (
                    trimmed.contains("File name:") ||
                    trimmed.contains("Created by") ||
                    trimmed.contains("Copyright")
                ) {
                    return true
                }
            }
        } catch {
            print("Error reading file: \(error)")
        }
        
        return false
    }
}

struct ProjectFile: Identifiable, Hashable {
    let id = UUID()
    let path: String
    let name: String
    let fileExtension: String
    let hasHeader: Bool
}

struct ProjectFileRow: View {
    let file: ProjectFile
    
    var body: some View {
        HStack {
            Image(systemName: iconForExtension(file.fileExtension))
                .foregroundColor(colorForExtension(file.fileExtension))
                .frame(width: 16)
            
            Text(file.name)
                .font(.system(.body, design: .monospaced))
            
            Spacer()
            
            if file.hasHeader {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .help("Has header")
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.secondary)
                    .help("No header")
            }
        }
        .padding(.vertical, 2)
    }
    
    private func iconForExtension(_ ext: String) -> String {
        switch ext {
        case "swift": return "swift"
        case "h", "hpp": return "h.square"
        case "m", "mm": return "m.square"
        case "cpp", "c": return "c.square"
        default: return "doc.text"
        }
    }
    
    private func colorForExtension(_ ext: String) -> Color {
        switch ext {
        case "swift": return .orange
        case "h", "hpp": return .blue
        case "m", "mm": return .purple
        case "cpp", "c": return .red
        default: return .gray
        }
    }
}

struct FileProcessorView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let projectFiles: [ProjectFile]
    let templateManager: TemplateManager
    
    @State private var selectedFiles: Set<ProjectFile> = []
    @State private var selectedTemplate: HeaderTemplate?
    @State private var isProcessing = false
    @State private var processedCount = 0
    @State private var errorMessages: [String] = []
    @State private var projectName = ""
    @State private var workspaceName = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Template Selection
                GroupBox("Template Selection") {
                    VStack(alignment: .leading, spacing: 8) {
                        Picker("Select Template", selection: $selectedTemplate) {
                            Text("Select a template...").tag(nil as HeaderTemplate?)
                            
                            ForEach(templateManager.projectTemplates) { template in
                                Text(template.name + " (Project)").tag(template as HeaderTemplate?)
                            }
                            
                            ForEach(templateManager.globalTemplates) { template in
                                Text(template.name + " (Global)").tag(template as HeaderTemplate?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        if let template = selectedTemplate {
                            Text("Extensions: \(template.fileExtensions.joined(separator: ", "))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Project Information
                GroupBox("Project Information") {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Project Name:")
                            TextField("Project name", text: $projectName)
                        }
                        
                        HStack {
                            Text("Workspace Name:")
                            TextField("Workspace name", text: $workspaceName)
                        }
                    }
                }
                
                // File Selection
                GroupBox("File Selection (\(selectedFiles.count) selected)") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Button("Select All") {
                                selectedFiles = Set(projectFiles)
                            }
                            
                            Button("Select None") {
                                selectedFiles.removeAll()
                            }
                            
                            Button("Select Files Without Headers") {
                                selectedFiles = Set(projectFiles.filter { !$0.hasHeader })
                            }
                        }
                        
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 4) {
                                ForEach(projectFiles) { file in
                                    HStack {
                                        Button(action: {
                                            if selectedFiles.contains(file) {
                                                selectedFiles.remove(file)
                                            } else {
                                                selectedFiles.insert(file)
                                            }
                                        }) {
                                            Image(systemName: selectedFiles.contains(file) ? "checkmark.square" : "square")
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                        
                                        ProjectFileRow(file: file)
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                    }
                }
                
                // Processing Status
                if isProcessing || processedCount > 0 {
                    GroupBox("Processing Status") {
                        VStack(alignment: .leading, spacing: 8) {
                            if isProcessing {
                                ProgressView("Processing files... (\(processedCount)/\(selectedFiles.count))")
                            } else {
                                Text("Processed \(processedCount) files successfully")
                                    .foregroundColor(.green)
                            }
                            
                            if !errorMessages.isEmpty {
                                Text("Errors:")
                                    .foregroundColor(.red)
                                
                                ForEach(errorMessages, id: \.self) { error in
                                    Text("• \(error)")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Action Buttons
                HStack {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    
                    Spacer()
                    
                    Button("Apply Template") {
                        applyTemplateToSelectedFiles()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedTemplate == nil || selectedFiles.isEmpty || isProcessing)
                }
            }
            .padding()
            .navigationTitle("Apply Templates to Files")
        }
        .frame(minWidth: 600, minHeight: 500)
        .onAppear {
            // Set default values
            if let projectPath = templateManager.currentProjectPath.split(separator: "/").last {
                projectName = String(projectPath)
                workspaceName = String(projectPath)
            }
            selectedTemplate = templateManager.selectedProjectTemplate ?? templateManager.selectedGlobalTemplate
        }
    }
    
    private func applyTemplateToSelectedFiles() {
        guard let template = selectedTemplate else { return }
        
        isProcessing = true
        processedCount = 0
        errorMessages.removeAll()
        
        DispatchQueue.global(qos: .userInitiated).async {
            for file in selectedFiles {
                do {
                    try templateManager.applyTemplateToFile(
                        at: file.path,
                        template: template,
                        projectName: projectName.isEmpty ? nil : projectName,
                        workspaceName: workspaceName.isEmpty ? nil : workspaceName
                    )
                    
                    DispatchQueue.main.async {
                        processedCount += 1
                    }
                } catch {
                    DispatchQueue.main.async {
                        errorMessages.append("\(file.name): \(error.localizedDescription)")
                    }
                }
            }
            
            DispatchQueue.main.async {
                isProcessing = false
            }
        }
    }
}

#Preview {
    ProjectSettingsView(templateManager: TemplateManager())
}
