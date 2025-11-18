//
//  File name: MacroOperationResult.swift
//  Project name: xcode-file-header-template
//  Workspace name: xcode-file-header-template
//
//  Created by: nothing-to-add on 13/11/2025
//  Using Swift 6.0
//  Copyright (c) 2023 nothing-to-add
//

import Foundation

typealias MacroResult = Result<MacroOperationSuccess, MacroOperationError>

enum MacroOperationSuccess {
    case added
    case updated
    case deleted
}

enum MacroOperationError: LocalizedError {
    case invalidName
    case invalidValue
    case duplicateName
    case notFound
    case saveFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidName:
            return "Invalid macro name"
        case .invalidValue:
            return "Invalid macro value"
        case .duplicateName:
            return "Macro with this name already exists"
        case .notFound:
            return "Macro not found"
        case .saveFailed(let error):
            return "Failed to save: \(error.localizedDescription)"
        }
    }
}
