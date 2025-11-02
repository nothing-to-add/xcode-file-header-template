//
//  File name: StringExtension.swift
//  Project name: xcode-file-header-template
//  Workspace name: xcode-file-header-template
//
//  Created by: nothing-to-add on 03/11/2025
//  Using Swift 6.0
//  Copyright (c) 2023 nothing-to-add
//

import Foundation

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
