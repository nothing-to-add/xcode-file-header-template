//
//  File name: FileHeaderTemplate.swift
//  Project name: xcode-file-header-template
//  Workspace name: xcode-file-header-template
//
//  Created by: nothing-to-add on 03/11/2025
//  Using Swift 6.0
//  Copyright (c) 2023 nothing-to-add
//

import Foundation

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
