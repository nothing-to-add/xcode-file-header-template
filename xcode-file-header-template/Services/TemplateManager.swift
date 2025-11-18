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
    @Published var globalMacros: [IDETemplateMacro] = []
    @Published var projectMacros: [IDETemplateMacro] = []
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
            .appendingPathComponent(projectIDETemplateMacrosFileName)
        
        // Initialize with all available template keys from the enum
        self.availableTemplateKeys = TemplateKeys.allKeys
        
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
        
        do {
            let data = try Data(contentsOf: effectiveGlobalMacrosURL)
            if let plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] {
                globalMacros = plist.compactMap { (key, value) in
                    guard let stringValue = value as? String else { return nil }
                    return IDETemplateMacro(name: key, value: stringValue)
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
            try saveGlobalMacrosWithError()
        } catch {
            Logger.shared.error("Failed to save global IDETemplateMacros: \(error)")
        }
    }
    
    private func getDefaultGlobalMacros() -> [IDETemplateMacro] {
        return [
            IDETemplateMacro(name: "FULLUSERNAME", value: NSFullUserName()),
            IDETemplateMacro(name: "COPYRIGHT", value: "Copyright © \(Calendar.current.component(.year, from: Date())) \(NSFullUserName()). All rights reserved."),
            IDETemplateMacro(name: "ORGANIZATIONNAME", value: "Your Organization"),
            IDETemplateMacro(name: "FILEHEADER", value: """
    //
    //  ___FILENAME___
    //  ___PROJECTNAME___
    //
    //  Created by ___FULLUSERNAME___ on ___DATE___.
    //  ___COPYRIGHT___
    //
    """)
        ]
    }
    
    func updateGlobalMacro(macro: IDETemplateMacro) -> MacroResult {
        guard !macro.name.isEmpty else {
            return .failure(.invalidName)
        }
        
        if globalMacros.contains(where: { $0.name == macro.name && $0.id != macro.id }) {
            return .failure(.duplicateName)
        }
        
        if let index = globalMacros.firstIndex(where: { $0.id == macro.id }) {
            globalMacros[index] = macro
            
            do {
                try saveGlobalMacrosWithError()
                return .success(.updated)
            } catch {
                return .failure(.saveFailed(error))
            }
        } else {
            globalMacros.append(macro)
            
            do {
                try saveGlobalMacrosWithError()
                return .success(.added)
            } catch {
                // Remove the added macro if save failed
                globalMacros.removeLast()
                return .failure(.saveFailed(error))
            }
        }
    }
    
    func deleteGlobalMacro(macro : IDETemplateMacro) -> MacroResult {
        guard let index = globalMacros.firstIndex(where: { $0.id == macro.id }) else {
            return .failure(.notFound)
        }
        
        let removedMacro = globalMacros.remove(at: index)
        
        do {
            try saveGlobalMacrosWithError()
            return .success(.deleted)
        } catch {
            // Restore the removed macro if save failed
            globalMacros.insert(removedMacro, at: index)
            return .failure(.saveFailed(error))
        }
    }
    
    func addCustomGlobalMacro(macro: IDETemplateMacro) -> MacroResult {
        guard !macro.name.isEmpty else {
            return .failure(.invalidName)
        }
        
        guard !globalMacros.contains(where: { $0.name == macro.name }) else {
            return .failure(.duplicateName)
        }
        
        globalMacros.append(macro)
        
        do {
            try saveGlobalMacrosWithError()
            return .success(.added)
        } catch {
            globalMacros.removeAll { $0.id == macro.id }
            return .failure(.saveFailed(error))
        }
    }
    
    // MARK: - Project IDETemplateMacros Management
    
    func loadProjectMacros(for projectPath: String) {
        currentProjectPath = projectPath
        let projectMacrosURL = URL(fileURLWithPath: projectPath).appendingPathComponent(projectIDETemplateMacrosFileName)
        
        do {
            let data = try Data(contentsOf: projectMacrosURL)
            if let plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] {
                projectMacros = plist.compactMap { (name, value) in
                    guard let stringValue = value as? String else { return nil }
                    return IDETemplateMacro(name: name, value: stringValue)
                }
            }
        } catch {
            Logger.shared.error("Failed to load project IDETemplateMacros: \(error)")
            projectMacros = []
        }
    }
    
    func saveProjectMacros() {
        do {
            try saveProjectMacrosWithError()
        } catch {
            Logger.shared.error("Failed to save project IDETemplateMacros: \(error)")
        }
    }
    
    func updateProjectMacro(macro: IDETemplateMacro) -> MacroResult {
        guard !macro.name.isEmpty else {
            return .failure(.invalidName)
        }
        
        if globalMacros.contains(where: { $0.name == macro.name && $0.id != macro.id }) {
            return .failure(.duplicateName)
        }
        
        if let index = projectMacros.firstIndex(where: { $0.id == macro.id }) {
            projectMacros[index] = macro
            
            do {
                try saveProjectMacrosWithError()
                return .success(.updated)
            } catch {
                return .failure(.saveFailed(error))
            }
        } else {
            projectMacros.append(macro)
            
            do {
                try saveProjectMacrosWithError()
                return .success(.added)
            } catch {
                projectMacros.removeLast()
                return .failure(.saveFailed(error))
            }
        }
    }
    
    func deleteProjectMacro(macro: IDETemplateMacro) -> MacroResult {
        guard let index = projectMacros.firstIndex(where: { $0.id == macro.id }) else {
            return .failure(.notFound)
        }
        
        let removedMacro = projectMacros.remove(at: index)
        
        do {
            try saveProjectMacrosWithError()
            return .success(.deleted)
        } catch {
            projectMacros.insert(removedMacro, at: index)
            return .failure(.saveFailed(error))
        }
    }
    
    func addCustomProjectMacro(macro: IDETemplateMacro) -> MacroResult {
        guard !macro.name.isEmpty else {
            return .failure(.invalidName)
        }
        
        guard !globalMacros.contains(where: { $0.name == macro.name }) else {
            return .failure(.duplicateName)
        }
        
        projectMacros.append(macro)
        
        do {
            try saveProjectMacrosWithError()
            return  .success(.added)
        } catch {
            projectMacros.removeAll { $0.id == macro.id }
            return .failure(.saveFailed(error))
        }
    }
    
    // MARK: - Fixed Save Methods with Error Throwing

    private func saveGlobalMacrosWithError() throws {
        let macroDict = Dictionary(uniqueKeysWithValues: globalMacros.map { ($0.name, $0.value) })
        
        let data = try PropertyListSerialization.data(fromPropertyList: macroDict, format: .xml, options: 0)
        try data.write(to: effectiveGlobalMacrosURL)
        Logger.shared.info("Successfully saved global IDETemplateMacros to: \(effectiveGlobalMacrosURL.path)")
    }

    private func saveProjectMacrosWithError() throws {
        guard !currentProjectPath.isEmpty else {
            throw MacroOperationError.invalidValue
        }
        
        let projectMacrosURL = URL(fileURLWithPath: currentProjectPath).appendingPathComponent(projectIDETemplateMacrosFileName)
        let macroDict = Dictionary(uniqueKeysWithValues: projectMacros.map { ($0.name, $0.value) })
        
        let data = try PropertyListSerialization.data(fromPropertyList: macroDict, format: .xml, options: 0)
        try data.write(to: projectMacrosURL)
        Logger.shared.info("Successfully saved project IDETemplateMacros to: \(projectMacrosURL.path)")
    }
    
    // MARK: - Template Keys Helper Methods
    
    /// Get description for a template key
    func getTemplateKeyDescription(for key: String) -> String {
        if let templateKey = TemplateKeys(rawValue: key) {
            return templateKey.description
        }
        return "Custom template macro"
    }
    
    /// Get display name for a template key
    func getTemplateKeyDisplayName(for key: String) -> String {
        if let templateKey = TemplateKeys(rawValue: key) {
            return templateKey.displayName
        }
        return key
    }
    
    /// Get category for a template key
    func getTemplateKeyCategory(for key: String) -> TemplateKeyCategory? {
        if let templateKey = TemplateKeys(rawValue: key) {
            return templateKey.category
        }
        return nil
    }
    
    /// Get all template keys grouped by category
    func getTemplateKeysGroupedByCategory() -> [TemplateKeyCategory: [TemplateKeys]] {
        return TemplateKeys.groupedByCategory
    }
    
    /// Check if a template key is a built-in Xcode key
    func isBuiltInTemplateKey(_ key: String) -> Bool {
        return TemplateKeys(rawValue: key) != nil
    }
    
    func createProjectMacrosFile() {
        guard !currentProjectPath.isEmpty else { return }
        
        if projectMacros.isEmpty {
            projectMacros = getDefaultProjectMacros()
        }
        saveProjectMacros()
    }
    
    private func getDefaultProjectMacros() -> [IDETemplateMacro] {
        let projectName = URL(fileURLWithPath: currentProjectPath).lastPathComponent
        let orgName = globalMacros.first(where: { $0.name == "ORGANIZATIONNAME" })?.value ?? "Your Organization"
        
        return [
            IDETemplateMacro(name: "PROJECTNAME", value: projectName),
            IDETemplateMacro(name: "ORGANIZATIONNAME", value: orgName)
        ]
    }
    
    // MARK: - Macro Value Resolution

    /// Resolves and merges all macros from both global and project sources into a single dictionary.
    ///
    /// This method is essential for the template system because:
    /// 1. **Hierarchy Resolution**: Project macros override global macros when keys conflict
    /// 2. **Template Processing**: Xcode's template engine expects a flat [String: String] dictionary
    /// 3. **Performance**: Pre-resolves all macro values once instead of lookup per replacement
    /// 4. **Consistency**: Ensures the same resolved values are used across all template operations
    /// 5. **Preview Generation**: Provides the exact macro values that will be used in actual file creation
    ///
    /// The resolution order is:
    /// - Global macros are added first (base layer)
    /// - Project macros override globals with same keys (override layer)
    /// - Built-in Xcode macros (like ___DATE___, ___TIME___) are handled separately during template processing
    ///
    /// - Returns: A dictionary where keys are macro names and values are resolved macro values
    func resolveAllMacros() -> Result<[String: String], MacroOperationError> {
        var resolved: [String: String] = [:]
        
            // Add global macros first (base layer)
            for macro in globalMacros {
                guard !macro.name.isEmpty else {
                    return .failure(.invalidName)
                }
                guard !macro.value.isEmpty else {
                    return .failure(.invalidValue)
                }
                resolved[macro.name] = macro.value
            }
            
            // Project macros override global ones (override layer)
            for macro in projectMacros {
                guard !macro.name.isEmpty else {
                    return .failure(.invalidName)
                }
                guard !macro.value.isEmpty else {
                    return .failure(.invalidValue)
                }
                resolved[macro.name] = macro.value
            }
            
            return .success(resolved)
    }
    
    func previewFileHeader() -> String {
        switch resolveAllMacros() {
        case .success(let resolvedMacros):
            // Get the file header template
            let defaultFileHeader = getDefaultGlobalMacros().first(where: { $0.name == "FILEHEADER" })?.value ?? ""
            var header = resolvedMacros["FILEHEADER"] ?? defaultFileHeader
            
            // Replace Xcode built-in placeholders with preview values
            // These are handled by Xcode's template engine in real usage
            header = header.replacingOccurrences(of: "___FILENAME___", with: "ExampleFile.swift")
            header = header.replacingOccurrences(of: "___FILEBASENAME___", with: "ExampleFile")
            header = header.replacingOccurrences(of: "___FILEBASENAMEASIDENTIFIER___", with: "ExampleFile")
            header = header.replacingOccurrences(of: "___PROJECTNAME___", with: resolvedMacros["PROJECTNAME"] ?? "MyProject")
            header = header.replacingOccurrences(of: "___PRODUCTNAME___", with: resolvedMacros["PRODUCTNAME"] ?? "MyProject")
            header = header.replacingOccurrences(of: "___WORKSPACENAME___", with: resolvedMacros["WORKSPACENAME"] ?? "MyProject")
            header = header.replacingOccurrences(of: "___FULLUSERNAME___", with: resolvedMacros["FULLUSERNAME"] ?? NSFullUserName())
            header = header.replacingOccurrences(of: "___USERNAME___", with: resolvedMacros["USERNAME"] ?? NSUserName())
            header = header.replacingOccurrences(of: "___DATE___", with: DateFormatter.shortDateFormatter.string(from: Date()))
            header = header.replacingOccurrences(of: "___TIME___", with: DateFormatter.shortDateFormatter.string(from: Date()))
            header = header.replacingOccurrences(of: "___YEAR___", with: "\(Calendar.current.component(.year, from: Date()))")
            header = header.replacingOccurrences(of: "___MONTH___", with: "\(Calendar.current.component(.month, from: Date()))")
            header = header.replacingOccurrences(of: "___DAY___", with: "\(Calendar.current.component(.day, from: Date()))")
            header = header.replacingOccurrences(of: "___COPYRIGHT___", with: resolvedMacros["COPYRIGHT"] ?? "")
            header = header.replacingOccurrences(of: "___ORGANIZATIONNAME___", with: resolvedMacros["ORGANIZATIONNAME"] ?? "")
            header = header.replacingOccurrences(of: "___CLASSPREFIX___", with: resolvedMacros["CLASSPREFIX"] ?? "")
            header = header.replacingOccurrences(of: "___PACKAGENAME___", with: resolvedMacros["PACKAGENAME"] ?? "MyPackage")
            header = header.replacingOccurrences(of: "___TARGETNAME___", with: resolvedMacros["TARGETNAME"] ?? "MyTarget")
            header = header.replacingOccurrences(of: "___SWIFTVERSION___", with: resolvedMacros["SWIFTVERSION"] ?? "6.0")
            header = header.replacingOccurrences(of: "___VERSION___", with: resolvedMacros["VERSION"] ?? "1.0")
            header = header.replacingOccurrences(of: "___BUILD___", with: resolvedMacros["BUILD"] ?? "1")
            header = header.replacingOccurrences(of: "___PLATFORM___", with: resolvedMacros["PLATFORM"] ?? "macOS")
            header = header.replacingOccurrences(of: "___XCODEVERSION___", with: resolvedMacros["XCODEVERSION"] ?? "15.0")
            header = header.replacingOccurrences(of: "___DEPLOYMENTTARGET___", with: resolvedMacros["DEPLOYMENTTARGET"] ?? "14.0")
            header = header.replacingOccurrences(of: "___COMPANYIDENTIFIER___", with: resolvedMacros["COMPANYIDENTIFIER"] ?? "com.example")
            header = header.replacingOccurrences(of: "___DEVELOPMENTTEAM___", with: resolvedMacros["DEVELOPMENTTEAM"] ?? "TEAM123")
            
            return header
            
        case .failure(let error):
            return "\(error)"
        }
    }
    
    /// Get the value of a specific macro from the resolved macro collection
    func getMacroValue(key: String) -> Result<String?, MacroOperationError> {
        switch resolveAllMacros() {
        case .success(let macros):
            return .success(macros[key])
        case .failure(let error):
            return .failure(error)
        }
    }

    /// Check if a specific macro key exists in the resolved collection
    func hasMacro(key: String) -> Result<Bool, MacroOperationError> {
        switch resolveAllMacros() {
        case .success(let macros):
            return .success(macros.keys.contains(key))
        case .failure(let error):
            return .failure(error)
        }
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
    
    func importGlobalMacros(from url: URL) -> Result<Int, MacroOperationError> {
        do {
            let data = try Data(contentsOf: url)
            guard let plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
                return .failure(MacroOperationError.invalidValue)
            }
            
            let importedMacros = plist.compactMap { (name, value) -> IDETemplateMacro? in
                guard let stringValue = value as? String else { return nil }
                return IDETemplateMacro(name: name, value: stringValue)
            }
            
            var importedCount = 0
            
            // Merge with existing macros
            for importedMacro in importedMacros {
                if let index = globalMacros.firstIndex(where: { $0.name == importedMacro.name }) {
                    globalMacros[index] = importedMacro
                } else {
                    globalMacros.append(importedMacro)
                }
                importedCount += 1
            }
            
            try saveGlobalMacrosWithError()
            return .success(importedCount)
            
        } catch {
            return .failure(.saveFailed(error))
        }
    }
}
