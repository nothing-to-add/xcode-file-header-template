//
//  File name: HeaderTemplate.swift
//  Project name: xcode-file-header-template
//  Workspace name: xcode-file-header-template
//
//  Created by: nothing-to-add on 21/10/2025
//  Using Swift 6.0
//  Copyright (c) 2023 nothing-to-add
//

import Foundation

/// Represents an Xcode Template Macro entry
struct IDETemplateMacro: Identifiable, Equatable, Hashable {
    let id = UUID()
    var key: String
    var value: String
    var isBuiltIn: Bool
    var description: String
    
    init(key: String, value: String, isBuiltIn: Bool = false, description: String = "") {
        self.key = key
        self.value = value
        self.isBuiltIn = isBuiltIn
        self.description = description.isEmpty ? Self.getDescription(for: key) : description
    }
    
    static func getDescription(for key: String) -> String {
        switch key {
        case "FILEHEADER":
            return "The header template for new files"
        case "FULLUSERNAME":
            return "The full name of the user"
        case "COPYRIGHT":
            return "Copyright notice"
        case "ORGANIZATIONNAME":
            return "Organization or company name"
        case "PROJECTNAME":
            return "Name of the current project"
        case "CLASSPREFIX":
            return "Prefix for new class names"
        default:
            return "Custom template macro"
        }
    }
    
    var isFileHeaderMacro: Bool {
        return key == "FILEHEADER"
    }
}

/// Built-in Xcode template macros that are commonly used
extension IDETemplateMacro {
    static let builtInMacros: [IDETemplateMacro] = [
        IDETemplateMacro(
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
            isBuiltIn: true
        ),
        IDETemplateMacro(
            key: "FULLUSERNAME",
            value: NSFullUserName(),
            isBuiltIn: true
        ),
        IDETemplateMacro(
            key: "COPYRIGHT",
            value: "Copyright © \(Calendar.current.component(.year, from: Date())) \(NSFullUserName()). All rights reserved.",
            isBuiltIn: true
        ),
        IDETemplateMacro(
            key: "ORGANIZATIONNAME",
            value: "Your Organization",
            isBuiltIn: true
        )
    ]
}

/// Represents different file header template presets
struct FileHeaderTemplate: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var content: String
    var description: String
    
    static let defaultTemplates: [FileHeaderTemplate] = [
        FileHeaderTemplate(
            name: "Standard",
            content: """
//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  ___COPYRIGHT___
//
""",
            description: "Standard Xcode file header with project, author, and copyright"
        ),
        
        FileHeaderTemplate(
            name: "Minimal",
            content: """
//  ___FILENAME___
//  Created by ___FULLUSERNAME___ on ___DATE___.
//
""",
            description: "Minimal header with just filename and author"
        ),
        
        FileHeaderTemplate(
            name: "Detailed",
            content: """
//
//  File: ___FILENAME___
//  Project: ___PROJECTNAME___
//  Organization: ___ORGANIZATIONNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  ___COPYRIGHT___
//
//  Description:
//  <#Brief description of the file's purpose#>
//
""",
            description: "Detailed header with organization and description placeholder"
        ),
        
        FileHeaderTemplate(
            name: "Company Style",
            content: """
////////////////////////////////////////////////////////////////////////////////
//
//  ___FILENAME___
//
//  ___PROJECTNAME___ | ___ORGANIZATIONNAME___
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  ___COPYRIGHT___
//
////////////////////////////////////////////////////////////////////////////////

""",
            description: "Corporate style header with decorative borders"
        )
    ]
}

/// Utility functions for working with Xcode template placeholders
extension String {
    /// Replaces Xcode template placeholders with actual values for preview
    func replacingXcodePlaceholders(
        filename: String = "ExampleFile.swift",
        projectName: String = "MyProject",
        fullUserName: String = NSFullUserName(),
        organizationName: String = "Your Organization",
        copyright: String? = nil
    ) -> String {
        let actualCopyright = copyright ?? "Copyright © \(Calendar.current.component(.year, from: Date())) \(fullUserName). All rights reserved."
        
        return self
            .replacingOccurrences(of: "___FILENAME___", with: filename)
            .replacingOccurrences(of: "___PROJECTNAME___", with: projectName)
            .replacingOccurrences(of: "___FULLUSERNAME___", with: fullUserName)
            .replacingOccurrences(of: "___ORGANIZATIONNAME___", with: organizationName)
            .replacingOccurrences(of: "___COPYRIGHT___", with: actualCopyright)
            .replacingOccurrences(of: "___DATE___", with: DateFormatter.xcodeDateFormatter.string(from: Date()))
    }
}

extension DateFormatter {
    static let xcodeDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}
