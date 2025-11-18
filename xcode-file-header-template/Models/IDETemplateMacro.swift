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
    var name: String
    var value: String
    var isBuiltIn: Bool
    var description: String
    var isGlobal: Bool
    
    init(name: String, value: String, isBuiltIn: Bool = false, description: String = "", isGlobal: Bool = false) {
        self.name = name
        self.value = value
        self.isBuiltIn = isBuiltIn
        self.description = description.isEmpty ? Self.getDescription(for: name) : description
        self.isGlobal = isGlobal
    }
    
    static func getDescription(for name: String) -> String {
        if let templateName = TemplateKeys(rawValue: name) {
            return templateName.description
        }
        return "Custom template macro"
    }
    
    var isFileHeaderMacro: Bool {
        return name == "FILEHEADER"
    }
}

/// Built-in Xcode template macros that are commonly used
extension IDETemplateMacro {
    static let builtInMacros: [IDETemplateMacro] = [
        IDETemplateMacro(
            name: "FILEHEADER",
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
            name: "FULLUSERNAME",
            value: NSFullUserName(),
            isBuiltIn: true
        ),
        IDETemplateMacro(
            name: "COPYRIGHT",
            value: "Copyright © \(Calendar.current.component(.year, from: Date())) \(NSFullUserName()). All rights reserved.",
            isBuiltIn: true
        ),
        IDETemplateMacro(
            name: "ORGANIZATIONNAME",
            value: "Your Organization",
            isBuiltIn: true
        )
    ]
}
