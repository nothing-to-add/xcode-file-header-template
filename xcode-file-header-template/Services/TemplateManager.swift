//
//  File name: TemplateManager.swift
//  Project name: xcode-file-header-template
//  Workspace name: xcode-file-header-template
//
//  Created by: nothing-to-add on 21/10/2025
//  Using Swift 6.0
//  Copyright (c) 2023 nothing-to-add
//

import Foundation
import SwiftUI
import Combine

class TemplateManager: ObservableObject {
    @Published var globalTemplates: [HeaderTemplate] = []
    @Published var projectTemplates: [HeaderTemplate] = []
    @Published var selectedGlobalTemplate: HeaderTemplate?
    @Published var selectedProjectTemplate: HeaderTemplate?
    @Published var currentProjectPath: String = ""
    
    private let globalTemplatesURL: URL
    private let projectTemplatesFileName = ".xcodeheader.json"
    
    init() {
        // Store global templates in Application Support
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("XcodeFileHeaderTemplate")
        self.globalTemplatesURL = appFolder.appendingPathComponent("GlobalTemplates.json")
        
        createDirectoryIfNeeded()
        loadGlobalTemplates()
        loadDefaultTemplatesIfEmpty()
    }
    
    // MARK: - Directory Management
    
    private func createDirectoryIfNeeded() {
        let directory = globalTemplatesURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: directory.path) {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - Global Templates
    
    func loadGlobalTemplates() {
        do {
            let data = try Data(contentsOf: globalTemplatesURL)
            globalTemplates = try JSONDecoder().decode([HeaderTemplate].self, from: data)
            selectedGlobalTemplate = globalTemplates.first
        } catch {
            print("Failed to load global templates: \(error)")
            globalTemplates = []
        }
    }
    
    func saveGlobalTemplates() {
        do {
            let data = try JSONEncoder().encode(globalTemplates)
            try data.write(to: globalTemplatesURL)
        } catch {
            print("Failed to save global templates: \(error)")
        }
    }
    
    private func loadDefaultTemplatesIfEmpty() {
        if globalTemplates.isEmpty {
            globalTemplates = [
                HeaderTemplate.defaultSwiftTemplate,
                HeaderTemplate.minimalTemplate
            ]
            selectedGlobalTemplate = globalTemplates.first
            saveGlobalTemplates()
        }
    }
    
    func addGlobalTemplate(_ template: HeaderTemplate) {
        var newTemplate = template
        newTemplate.isGlobal = true
        globalTemplates.append(newTemplate)
        saveGlobalTemplates()
    }
    
    func updateGlobalTemplate(_ template: HeaderTemplate) {
        if let index = globalTemplates.firstIndex(where: { $0.id == template.id }) {
            var updatedTemplate = template
            updatedTemplate.lastModified = Date()
            globalTemplates[index] = updatedTemplate
            saveGlobalTemplates()
        }
    }
    
    func deleteGlobalTemplate(_ template: HeaderTemplate) {
        globalTemplates.removeAll { $0.id == template.id }
        if selectedGlobalTemplate?.id == template.id {
            selectedGlobalTemplate = globalTemplates.first
        }
        saveGlobalTemplates()
    }
    
    // MARK: - Project Templates
    
    func loadProjectTemplates(for projectPath: String) {
        currentProjectPath = projectPath
        let projectTemplateURL = URL(fileURLWithPath: projectPath).appendingPathComponent(projectTemplatesFileName)
        
        do {
            let data = try Data(contentsOf: projectTemplateURL)
            projectTemplates = try JSONDecoder().decode([HeaderTemplate].self, from: data)
            selectedProjectTemplate = projectTemplates.first
        } catch {
            print("Failed to load project templates: \(error)")
            projectTemplates = []
            selectedProjectTemplate = nil
        }
    }
    
    func saveProjectTemplates() {
        guard !currentProjectPath.isEmpty else { return }
        
        let projectTemplateURL = URL(fileURLWithPath: currentProjectPath).appendingPathComponent(projectTemplatesFileName)
        
        do {
            let data = try JSONEncoder().encode(projectTemplates)
            try data.write(to: projectTemplateURL)
        } catch {
            print("Failed to save project templates: \(error)")
        }
    }
    
    func addProjectTemplate(_ template: HeaderTemplate) {
        var newTemplate = template
        newTemplate.isGlobal = false
        newTemplate.projectPath = currentProjectPath
        projectTemplates.append(newTemplate)
        saveProjectTemplates()
    }
    
    func updateProjectTemplate(_ template: HeaderTemplate) {
        if let index = projectTemplates.firstIndex(where: { $0.id == template.id }) {
            var updatedTemplate = template
            updatedTemplate.lastModified = Date()
            projectTemplates[index] = updatedTemplate
            saveProjectTemplates()
        }
    }
    
    func deleteProjectTemplate(_ template: HeaderTemplate) {
        projectTemplates.removeAll { $0.id == template.id }
        if selectedProjectTemplate?.id == template.id {
            selectedProjectTemplate = projectTemplates.first
        }
        saveProjectTemplates()
    }
    
    // MARK: - Template Application
    
    func applyTemplateToFile(at filePath: String, template: HeaderTemplate, projectName: String? = nil, workspaceName: String? = nil) throws {
        let fileURL = URL(fileURLWithPath: filePath)
        
        // Read existing file content
        let existingContent = try String(contentsOf: fileURL)
        
        // Remove existing header if present
        let contentWithoutHeader = removeExistingHeader(from: existingContent)
        
        // Generate new header
        let newHeader = template.generateHeader(for: filePath, projectName: projectName, workspaceName: workspaceName)
        
        // Combine header with content
        let newContent = newHeader + "\n" + contentWithoutHeader
        
        // Write back to file
        try newContent.write(to: fileURL, atomically: true, encoding: .utf8)
    }
    
    private func removeExistingHeader(from content: String) -> String {
        let lines = content.components(separatedBy: .newlines)
        var startIndex = 0
        
        // Skip initial comment lines
        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if trimmedLine.isEmpty || trimmedLine.hasPrefix("//") {
                startIndex = index + 1
            } else {
                break
            }
        }
        
        return lines.dropFirst(startIndex).joined(separator: "\n")
    }
    
    // MARK: - Project Detection
    
    func findXcodeProjects(in directoryPath: String) -> [String] {
        guard let enumerator = FileManager.default.enumerator(atPath: directoryPath) else { return [] }
        
        var projects: [String] = []
        
        while let file = enumerator.nextObject() as? String {
            if file.hasSuffix(".xcodeproj") {
                let fullPath = URL(fileURLWithPath: directoryPath).appendingPathComponent(file).path
                projects.append(fullPath)
            }
        }
        
        return projects
    }
    
    func getActiveTemplate(for filePath: String) -> HeaderTemplate? {
        let fileExtension = URL(fileURLWithPath: filePath).pathExtension
        
        // First check project-specific templates
        if let projectTemplate = projectTemplates.first(where: { $0.fileExtensions.contains(fileExtension) }) {
            return projectTemplate
        }
        
        // Fallback to selected project template or global template
        return selectedProjectTemplate ?? selectedGlobalTemplate ?? globalTemplates.first
    }
}
