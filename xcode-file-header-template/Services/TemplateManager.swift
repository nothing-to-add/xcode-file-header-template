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
    @Published var hasRealXcodeAccess: Bool = false
    
    private let globalIDETemplateMacrosURL: URL
    private let projectIDETemplateMacrosFileName = "IDETemplateMacros.plist"
    
    init() {
        // Path to Xcode's global IDETemplateMacros.plist
        // For App Store compliance, we'll use the sandboxed path initially
        // and provide user options to select the real Xcode directory
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
        
        // Check if we need to request access on first launch
        checkAndRequestAccessIfNeeded()
    }
    
    // MARK: - Directory Management
    
    private func createXcodeUserDataDirectoryIfNeeded() {
        let directory = globalIDETemplateMacrosURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: directory.path) {
            Logger.shared.info("Creating missing Xcode UserData directory: \(directory.path)")
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - Global IDETemplateMacros Management
    
    func loadGlobalMacros() {
        // Try to load from custom location first
        _ = loadCustomGlobalMacrosLocation()
        
        Logger.shared.info("Global IDE Template Macros url: \(effectiveGlobalMacrosURL.path)")
        do {
            let data = try Data(contentsOf: effectiveGlobalMacrosURL)
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
            try data.write(to: effectiveGlobalMacrosURL)
            Logger.shared.info("Successfully saved global IDETemplateMacros to: \(effectiveGlobalMacrosURL.path)")
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
    
    // MARK: - App Store Compliant File Access
    
    private var customGlobalMacrosURL: URL?
    
    private func checkAndRequestAccessIfNeeded() {
        // Check if we already have access
        if loadCustomGlobalMacrosLocation() {
            return // Already have access
        }
        
        // Check if this is first launch or if we're in sandboxed mode without access
        let hasRequestedBefore = UserDefaults.standard.bool(forKey: "HasRequestedXcodeAccess")
        
        if !hasRequestedBefore {
            // First launch - automatically request access
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.requestXcodeAccessWithUserFriendlyPrompt()
            }
        }
    }
    
    func requestXcodeAccessWithUserFriendlyPrompt() {
        let alert = NSAlert()
        alert.messageText = "Access to Xcode Settings Required"
        alert.informativeText = """
        To manage your Xcode file header templates, this app needs access to your Xcode UserData folder.
        
        This allows the app to read and modify your IDETemplateMacros.plist file, which controls how Xcode generates file headers.
        
        You'll be asked to select the folder: ~/Library/Developer/Xcode/UserData
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Grant Access")
        alert.addButton(withTitle: "Use Limited Mode")
        alert.addButton(withTitle: "Learn More")
        
        let response = alert.runModal()
        
        UserDefaults.standard.set(true, forKey: "HasRequestedXcodeAccess")
        
        switch response {
        case .alertFirstButtonReturn: // Grant Access
            if !selectCustomGlobalMacrosLocation() {
                // User cancelled, show fallback options
                showAccessFailedAlert()
            }
        case .alertSecondButtonReturn: // Use Limited Mode
            showLimitedModeInfo()
        case .alertThirdButtonReturn: // Learn More
            showLearnMoreInfo()
            // Ask again after showing info
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.requestXcodeAccessWithUserFriendlyPrompt()
            }
        default:
            break
        }
    }
    
    private func showAccessFailedAlert() {
        let alert = NSAlert()
        alert.messageText = "Access Not Granted"
        alert.informativeText = """
        The app will work in limited mode using a sandboxed environment.
        
        You can grant access later through Settings → IDETemplateMacros → "Select Xcode UserData Folder"
        """
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Continue")
        alert.addButton(withTitle: "Try Again")
        
        if alert.runModal() == .alertSecondButtonReturn {
            requestXcodeAccessWithUserFriendlyPrompt()
        }
    }
    
    private func showLimitedModeInfo() {
        let alert = NSAlert()
        alert.messageText = "Limited Mode Active"
        alert.informativeText = """
        The app is running in limited mode and will manage templates in a sandboxed environment.
        
        Changes made here won't affect Xcode's actual file header templates until you grant access to the Xcode UserData folder.
        
        You can enable full functionality anytime through Settings.
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func showLearnMoreInfo() {
        let alert = NSAlert()
        alert.messageText = "Why Access is Needed"
        alert.informativeText = """
        Xcode stores file header templates in:
        ~/Library/Developer/Xcode/UserData/IDETemplateMacros.plist
        
        This app modifies that file to customize how Xcode generates headers for new files.
        
        Due to macOS security (App Sandbox), apps can't access system directories without explicit user permission.
        
        The app will guide you to select the correct folder.
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    func selectCustomGlobalMacrosLocation() -> Bool {
        let panel = NSOpenPanel()
        panel.message = "Navigate to ~/Library/Developer/Xcode/UserData and click 'Select Folder'"
        panel.prompt = "Select UserData Folder"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = false
        
        // Try to navigate directly to the Xcode folder or as close as possible
        let homeDir = URL(fileURLWithPath: NSHomeDirectory())
        let libraryDir = homeDir.appendingPathComponent("Library")
        let developerDir = libraryDir.appendingPathComponent("Developer")
        let xcodeDir = developerDir.appendingPathComponent("Xcode")
        let xcodeUserData = xcodeDir.appendingPathComponent("UserData")
        
        // Navigate to the closest existing directory
        if FileManager.default.fileExists(atPath: xcodeUserData.path) {
            panel.directoryURL = xcodeUserData
            panel.message = "Perfect! This is the UserData folder. Click 'Select Folder' to grant access."
        } else if FileManager.default.fileExists(atPath: xcodeDir.path) {
            panel.directoryURL = xcodeDir
            panel.message = "Navigate to the 'UserData' folder inside this Xcode folder, then click 'Select Folder'"
        } else if FileManager.default.fileExists(atPath: developerDir.path) {
            panel.directoryURL = developerDir
            panel.message = "Navigate to Xcode → UserData folder, then click 'Select Folder'"
        } else if FileManager.default.fileExists(atPath: libraryDir.path) {
            panel.directoryURL = libraryDir
            panel.message = "Navigate to Developer → Xcode → UserData folder, then click 'Select Folder'"
        } else {
            panel.directoryURL = homeDir
            panel.message = "Navigate to Library → Developer → Xcode → UserData folder, then click 'Select Folder'"
        }
        
        if panel.runModal() == .OK, let selectedURL = panel.url {
            // Validate that this looks like the UserData folder
            let macrosURL = selectedURL.appendingPathComponent("IDETemplateMacros.plist")
            let isUserDataFolder = selectedURL.lastPathComponent == "UserData" && 
                                   selectedURL.pathComponents.contains("Xcode")
            
            if !isUserDataFolder {
                // Show helpful error
                let alert = NSAlert()
                alert.messageText = "Incorrect Folder Selected"
                alert.informativeText = """
                Please select the UserData folder located at:
                ~/Library/Developer/Xcode/UserData
                
                Selected: \(selectedURL.path)
                Expected: A folder named 'UserData' inside your Xcode directory
                """
                alert.alertStyle = .warning
                alert.addButton(withTitle: "Try Again")
                alert.addButton(withTitle: "Use This Folder Anyway")
                
                if alert.runModal() == .alertFirstButtonReturn {
                    return selectCustomGlobalMacrosLocation()
                }
            }
            
            customGlobalMacrosURL = macrosURL
            
            // Store the bookmark for future access
            do {
                let bookmarkData = try selectedURL.bookmarkData(options: .withSecurityScope, 
                                                               includingResourceValuesForKeys: nil, 
                                                               relativeTo: nil)
                UserDefaults.standard.set(bookmarkData, forKey: "XcodeUserDataBookmark")
                hasRealXcodeAccess = true
                
                // Reload macros with new access
                loadGlobalMacros()
                
                // Show success message
                DispatchQueue.main.async {
                    let successAlert = NSAlert()
                    successAlert.messageText = "Access Granted Successfully!"
                    successAlert.informativeText = "The app now has access to your Xcode file header templates."
                    successAlert.alertStyle = .informational
                    successAlert.addButton(withTitle: "Great!")
                    successAlert.runModal()
                }
                
                return true
            } catch {
                Logger.shared.error("Failed to create bookmark: \(error)")
                
                let errorAlert = NSAlert()
                errorAlert.messageText = "Failed to Save Access Permissions"
                errorAlert.informativeText = "Error: \(error.localizedDescription)"
                errorAlert.alertStyle = .critical
                errorAlert.addButton(withTitle: "OK")
                errorAlert.runModal()
                
                return false
            }
        }
        return false
    }
    
    func loadCustomGlobalMacrosLocation() -> Bool {
        guard let bookmarkData = UserDefaults.standard.data(forKey: "XcodeUserDataBookmark") else {
            hasRealXcodeAccess = false
            return false
        }
        
        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData, 
                             options: .withSecurityScope, 
                             relativeTo: nil, 
                             bookmarkDataIsStale: &isStale)
            
            if !isStale && url.startAccessingSecurityScopedResource() {
                customGlobalMacrosURL = url.appendingPathComponent("IDETemplateMacros.plist")
                hasRealXcodeAccess = true
                return true
            }
        } catch {
            Logger.shared.error("Failed to resolve bookmark: \(error)")
        }
        hasRealXcodeAccess = false
        return false
    }
    
    private var effectiveGlobalMacrosURL: URL {
        return customGlobalMacrosURL ?? globalIDETemplateMacrosURL
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
