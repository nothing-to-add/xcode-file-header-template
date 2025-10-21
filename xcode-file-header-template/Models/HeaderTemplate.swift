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

struct HeaderTemplate: Codable, Identifiable, Equatable, Hashable {
    let id = UUID()
    var name: String
    var content: String
    var isGlobal: Bool
    var projectPath: String? // Only for project-specific templates
    var variables: [TemplateVariable]
    var fileExtensions: [String] // Which file types this template applies to
    var createdDate: Date
    var lastModified: Date
    
    init(name: String, content: String, isGlobal: Bool = true, projectPath: String? = nil, fileExtensions: [String] = ["swift"]) {
        self.name = name
        self.content = content
        self.isGlobal = isGlobal
        self.projectPath = projectPath
        self.variables = TemplateVariable.defaultVariables
        self.fileExtensions = fileExtensions
        self.createdDate = Date()
        self.lastModified = Date()
    }
    
    /// Generates the actual header content by replacing variables
    func generateHeader(for filePath: String, projectName: String? = nil, workspaceName: String? = nil) -> String {
        var result = content
        
        // Replace built-in variables
        result = result.replacingOccurrences(of: "{{FILE_NAME}}", with: URL(fileURLWithPath: filePath).lastPathComponent)
        result = result.replacingOccurrences(of: "{{PROJECT_NAME}}", with: projectName ?? "Unknown Project")
        result = result.replacingOccurrences(of: "{{WORKSPACE_NAME}}", with: workspaceName ?? "Unknown Workspace")
        result = result.replacingOccurrences(of: "{{DATE}}", with: DateFormatter.headerDateFormatter.string(from: Date()))
        result = result.replacingOccurrences(of: "{{YEAR}}", with: DateFormatter.yearFormatter.string(from: Date()))
        
        // Replace custom variables
        for variable in variables {
            let placeholder = "{{\(variable.name.uppercased())}}"
            result = result.replacingOccurrences(of: placeholder, with: variable.value)
        }
        
        return result
    }
    
    /// Default Swift template
    static let defaultSwiftTemplate = HeaderTemplate(
        name: "Default Swift",
        content: """
        //
        //  File name: {{FILE_NAME}}
        //  Project name: {{PROJECT_NAME}}
        //  Workspace name: {{WORKSPACE_NAME}}
        //
        //  Created by: {{AUTHOR}} on {{DATE}}
        //  Using Swift {{SWIFT_VERSION}}
        //  Copyright (c) {{YEAR}} {{ORGANIZATION}}
        //
        """,
        fileExtensions: ["swift"]
    )
    
    /// Minimal template
    static let minimalTemplate = HeaderTemplate(
        name: "Minimal",
        content: """
        //  {{FILE_NAME}}
        //  Created by {{AUTHOR}} on {{DATE}}.
        //
        """,
        fileExtensions: ["swift"]
    )
}

struct TemplateVariable: Codable, Identifiable, Equatable, Hashable {
    let id = UUID()
    var name: String
    var value: String
    var description: String
    
    static let defaultVariables: [TemplateVariable] = [
        TemplateVariable(name: "AUTHOR", value: NSFullUserName(), description: "Author name"),
        TemplateVariable(name: "ORGANIZATION", value: "Your Organization", description: "Organization name"),
        TemplateVariable(name: "SWIFT_VERSION", value: "6.0", description: "Swift version")
    ]
}

extension DateFormatter {
    static let headerDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
    
    static let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
}
