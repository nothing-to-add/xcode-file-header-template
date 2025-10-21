//
//  File name: FileProcessorUtility.swift
//  Project name: xcode-file-header-template
//  Workspace name: xcode-file-header-template
//
//  Created by: nothing-to-add on 21/10/2025
//  Using Swift 6.0
//  Copyright (c) 2023 nothing-to-add
//

import Foundation

class FileProcessorUtility {
    static let shared = FileProcessorUtility()
    
    private init() {}
    
    /// Batch process multiple files with templates
    func batchProcessFiles(
        files: [ProjectFile],
        template: HeaderTemplate,
        projectName: String?,
        workspaceName: String?,
        progressCallback: @escaping (Int, String?) -> Void
    ) async {
        for (index, file) in files.enumerated() {
            do {
                try applyTemplateToFile(
                    at: file.path,
                    template: template,
                    projectName: projectName,
                    workspaceName: workspaceName
                )
                
                await MainActor.run {
                    progressCallback(index + 1, nil)
                }
            } catch {
                await MainActor.run {
                    progressCallback(index + 1, "\(file.name): \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Apply template to a single file
    func applyTemplateToFile(
        at filePath: String,
        template: HeaderTemplate,
        projectName: String?,
        workspaceName: String?
    ) throws {
        let fileURL = URL(fileURLWithPath: filePath)
        
        // Read existing file content
        let existingContent = try String(contentsOf: fileURL)
        
        // Remove existing header if present
        let contentWithoutHeader = removeExistingHeader(from: existingContent)
        
        // Generate new header
        let newHeader = template.generateHeader(
            for: filePath,
            projectName: projectName,
            workspaceName: workspaceName
        )
        
        // Combine header with content
        let newContent = newHeader + "\n" + contentWithoutHeader
        
        // Write back to file
        try newContent.write(to: fileURL, atomically: true, encoding: .utf8)
    }
    
    /// Remove existing header comments from file content
    private func removeExistingHeader(from content: String) -> String {
        let lines = content.components(separatedBy: .newlines)
        var contentStartIndex = 0
        var inHeaderBlock = false
        
        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Empty line
            if trimmedLine.isEmpty {
                continue
            }
            
            // Comment line
            if trimmedLine.hasPrefix("//") {
                inHeaderBlock = true
                continue
            }
            
            // If we were in a header block and now hit non-comment content
            if inHeaderBlock && !trimmedLine.hasPrefix("//") {
                // Check if this is an import or other code
                if trimmedLine.hasPrefix("import") || 
                   trimmedLine.hasPrefix("class") ||
                   trimmedLine.hasPrefix("struct") ||
                   trimmedLine.hasPrefix("enum") ||
                   trimmedLine.hasPrefix("func") ||
                   trimmedLine.hasPrefix("var") ||
                   trimmedLine.hasPrefix("let") ||
                   trimmedLine.hasPrefix("@") ||
                   trimmedLine.hasPrefix("#") {
                    contentStartIndex = index
                    break
                }
            }
            
            // If we hit actual content without being in a header block
            if !inHeaderBlock {
                contentStartIndex = index
                break
            }
        }
        
        return lines.dropFirst(contentStartIndex).joined(separator: "\n")
    }
    
    /// Analyze project structure to determine appropriate template settings
    func analyzeProject(at path: String) -> ProjectAnalysis {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(atPath: path) else {
            return ProjectAnalysis(projectName: "Unknown", hasSwiftFiles: false, hasObjCFiles: false, totalFiles: 0)
        }
        
        var swiftFiles = 0
        var objcFiles = 0
        var totalFiles = 0
        
        while let file = enumerator.nextObject() as? String {
            let ext = URL(fileURLWithPath: file).pathExtension
            
            // Skip build artifacts and hidden files
            if file.contains(".xcodeproj/") || 
               file.contains(".git/") ||
               file.contains("Pods/") ||
               file.hasPrefix(".") {
                continue
            }
            
            switch ext {
            case "swift":
                swiftFiles += 1
                totalFiles += 1
            case "h", "m", "mm":
                objcFiles += 1
                totalFiles += 1
            case "cpp", "c", "hpp":
                totalFiles += 1
            default:
                break
            }
        }
        
        let projectName = URL(fileURLWithPath: path).lastPathComponent
            .replacingOccurrences(of: ".xcodeproj", with: "")
        
        return ProjectAnalysis(
            projectName: projectName,
            hasSwiftFiles: swiftFiles > 0,
            hasObjCFiles: objcFiles > 0,
            totalFiles: totalFiles
        )
    }
    
    /// Extract Xcode project information
    func extractXcodeProjectInfo(from projectPath: String) -> XcodeProjectInfo? {
        // Look for .xcodeproj in the directory
        let fileManager = FileManager.default
        
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: projectPath)
            
            for item in contents {
                if item.hasSuffix(".xcodeproj") {
                    let projectName = item.replacingOccurrences(of: ".xcodeproj", with: "")
                    
                    // Try to find workspace name
                    let workspaceName = contents.first { $0.hasSuffix(".xcworkspace") }?
                        .replacingOccurrences(of: ".xcworkspace", with: "") ?? projectName
                    
                    return XcodeProjectInfo(
                        projectName: projectName,
                        workspaceName: workspaceName,
                        projectPath: URL(fileURLWithPath: projectPath).appendingPathComponent(item).path
                    )
                }
            }
        } catch {
            print("Error reading project directory: \(error)")
        }
        
        return nil
    }
}

struct ProjectAnalysis {
    let projectName: String
    let hasSwiftFiles: Bool
    let hasObjCFiles: Bool
    let totalFiles: Int
}

struct XcodeProjectInfo {
    let projectName: String
    let workspaceName: String
    let projectPath: String
}
