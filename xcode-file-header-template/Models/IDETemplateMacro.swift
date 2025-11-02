//
//  File name: IDETemplateMacro.swift
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
