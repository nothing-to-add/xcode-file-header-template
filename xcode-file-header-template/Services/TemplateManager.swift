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
import CustomLogger

class TemplateManager: ObservableObject {
    @Published var globalMacros: [String: String] = [:]
    @Published var projectMacros: [String: String] = [:]
    @Published var currentProjectPath: String = ""
    @Published var availableTemplateKeys: [String] = []
    
    private let globalIDETemplateMacrosURL: URL
    private let projectIDETemplateMacrosFileName = "IDETemplateMacros.plist"
    
    init() {
        // Path to Xcode's global IDETemplateMacros.plist
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        self.globalIDETemplateMacrosURL = homeDirectory
            .appendingPathComponent("Library")
            .appendingPathComponent("Developer")
            .appendingPathComponent("Xcode")
            .appendingPathComponent("UserData")
            .appendingPathComponent("IDETemplateMacros.plist")
        
        // Common Xcode template macro keys
        self.availableTemplateKeys = [
            "FILEHEADER",
            "FULLUSERNAME", 
            "COPYRIGHT",
            "ORGANIZATIONNAME",
            "PROJECTNAME",
            "CLASSPREFIX"
        ]
        
        createXcodeUserDataDirectoryIfNeeded()
        loadGlobalMacros()
    }
    
    // MARK: - Directory Management
    
    private func createXcodeUserDataDirectoryIfNeeded() {
        let directory = globalIDETemplateMacrosURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: directory.path) {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - Global IDETemplateMacros Management
    
    func loadGlobalMacros() {
        do {
            let data = try Data(contentsOf: globalIDETemplateMacrosURL)
            if let plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] {
                globalMacros = plist.compactMapValues { value in
                    return value as? String
                }
            }
        } catch {
            Logger.shared.error("Failed to load global IDETemplateMacros: \(error)")
            globalMacros = getDefaultGlobalMacros()
        }
        
        // Ensure we have at least default values
        if globalMacros.isEmpty {
            globalMacros = getDefaultGlobalMacros()
            saveGlobalMacros()
        }
    }
    
    func saveGlobalMacros() {
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: globalMacros, format: .xml, options: 0)
            try data.write(to: globalIDETemplateMacrosURL)
            Logger.shared.info("Successfully saved global IDETemplateMacros to: \(globalIDETemplateMacrosURL.path)")
        } catch {
            Logger.shared.error("Failed to save global IDETemplateMacros: \(error)")
        }
    }
    
    private func getDefaultGlobalMacros() -> [String: String] {
        return [
            "FULLUSERNAME": NSFullUserName(),
            "COPYRIGHT": "Copyright © \(Calendar.current.component(.year, from: Date())) \(NSFullUserName()). All rights reserved.",
            "ORGANIZATIONNAME": "Your Organization",
            "FILEHEADER": """
//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  ___COPYRIGHT___
//
"""
        ]
    }
    
    func updateGlobalMacro(key: String, value: String) {
        globalMacros[key] = value
        saveGlobalMacros()
    }
    
    func deleteGlobalMacro(key: String) {
        globalMacros.removeValue(forKey: key)
        saveGlobalMacros()
    }
    
    func addCustomGlobalMacro(key: String, value: String) {
        globalMacros[key] = value
        if !availableTemplateKeys.contains(key) {
            availableTemplateKeys.append(key)
        }
        saveGlobalMacros()
    }
    
    // MARK: - Project IDETemplateMacros Management
    
    func loadProjectMacros(for projectPath: String) {
        currentProjectPath = projectPath
        let projectMacrosURL = URL(fileURLWithPath: projectPath).appendingPathComponent(projectIDETemplateMacrosFileName)
        
        do {
            let data = try Data(contentsOf: projectMacrosURL)
            if let plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] {
                projectMacros = plist.compactMapValues { value in
                    return value as? String
                }
            }
        } catch {
            Logger.shared.error("Failed to load project IDETemplateMacros: \(error)")
            projectMacros = [:]
        }
    }
    
    func saveProjectMacros() {
        guard !currentProjectPath.isEmpty else { return }
        
        let projectMacrosURL = URL(fileURLWithPath: currentProjectPath).appendingPathComponent(projectIDETemplateMacrosFileName)
        
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: projectMacros, format: .xml, options: 0)
            try data.write(to: projectMacrosURL)
            Logger.shared.info("Successfully saved project IDETemplateMacros to: \(projectMacrosURL.path)")
        } catch {
            Logger.shared.error("Failed to save project IDETemplateMacros: \(error)")
        }
    }
    
    func updateProjectMacro(key: String, value: String) {
        projectMacros[key] = value
        saveProjectMacros()
    }
    
    func deleteProjectMacro(key: String) {
        projectMacros.removeValue(forKey: key)
        saveProjectMacros()
    }
    
    func addCustomProjectMacro(key: String, value: String) {
        projectMacros[key] = value
        if !availableTemplateKeys.contains(key) {
            availableTemplateKeys.append(key)
        }
        saveProjectMacros()
    }
    
    func createProjectMacrosFile() {
        guard !currentProjectPath.isEmpty else { return }
        
        if projectMacros.isEmpty {
            projectMacros = getDefaultProjectMacros()
        }
        saveProjectMacros()
    }
    
    private func getDefaultProjectMacros() -> [String: String] {
        let projectName = URL(fileURLWithPath: currentProjectPath).lastPathComponent
        return [
            "PROJECTNAME": projectName,
            "ORGANIZATIONNAME": globalMacros["ORGANIZATIONNAME"] ?? "Your Organization"
        ]
    }
    
    // MARK: - Macro Value Resolution
    
    func resolveAllMacros() -> [String: String] {
        var resolved = globalMacros
        
        // Project macros override global ones
        for (key, value) in projectMacros {
            resolved[key] = value
        }
        
        return resolved
    }
    
    func previewFileHeader() -> String {
        let resolvedMacros = resolveAllMacros()
        var header = resolvedMacros["FILEHEADER"] ?? getDefaultGlobalMacros()["FILEHEADER"]!
        
        // Replace Xcode built-in placeholders with preview values
        header = header.replacingOccurrences(of: "___FILENAME___", with: "ExampleFile.swift")
        header = header.replacingOccurrences(of: "___PROJECTNAME___", with: resolvedMacros["PROJECTNAME"] ?? "MyProject")
        header = header.replacingOccurrences(of: "___FULLUSERNAME___", with: resolvedMacros["FULLUSERNAME"] ?? NSFullUserName())
        header = header.replacingOccurrences(of: "___DATE___", with: DateFormatter.shortDateFormatter.string(from: Date()))
        header = header.replacingOccurrences(of: "___COPYRIGHT___", with: resolvedMacros["COPYRIGHT"] ?? "")
        header = header.replacingOccurrences(of: "___ORGANIZATIONNAME___", with: resolvedMacros["ORGANIZATIONNAME"] ?? "")
        
        return header
    }
    
    // MARK: - Backup and Restore
    
    func backupGlobalMacros() throws -> URL {
        let backupURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("IDETemplateMacros_backup_\(Date().timeIntervalSince1970)")
            .appendingPathExtension("plist")
        
        try FileManager.default.copyItem(at: globalIDETemplateMacrosURL, to: backupURL)
        return backupURL
    }
    
    func restoreGlobalMacros(from backupURL: URL) throws {
        try FileManager.default.copyItem(at: backupURL, to: globalIDETemplateMacrosURL)
        loadGlobalMacros()
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
    
    func hasProjectMacros(at projectPath: String) -> Bool {
        let projectMacrosURL = URL(fileURLWithPath: projectPath).appendingPathComponent(projectIDETemplateMacrosFileName)
        return FileManager.default.fileExists(atPath: projectMacrosURL.path)
    }
    
    // MARK: - Import/Export
    
    func exportGlobalMacros() -> URL? {
        let desktop = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        let exportURL = desktop.appendingPathComponent("IDETemplateMacros_export.plist")
        
        do {
            try FileManager.default.copyItem(at: globalIDETemplateMacrosURL, to: exportURL)
            return exportURL
        } catch {
            Logger.shared.error("Failed to export global macros: \(error)")
            return nil
        }
    }
    
    func importGlobalMacros(from url: URL) throws {
        let data = try Data(contentsOf: url)
        if let plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] {
            let importedMacros = plist.compactMapValues { value in
                return value as? String
            }
            
            // Merge with existing macros
            for (key, value) in importedMacros {
                globalMacros[key] = value
            }
            
            saveGlobalMacros()
        }
    }
}
