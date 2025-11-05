//
//  File name: TemplateKeys.swift
//  Project name: xcode-file-header-template
//  Workspace name: xcode-file-header-template
//
//  Created by: nothing-to-add on 06/11/2025
//  Using Swift 6.0
//  Copyright (c) 2023 nothing-to-add
//

import Foundation

/// Enum containing all available Xcode template macro keys with descriptions
enum TemplateKeys: String, CaseIterable, Identifiable {
    
    // MARK: - Core Template Keys
    case fileHeader = "FILEHEADER"
    case fullUserName = "FULLUSERNAME"
    case copyright = "COPYRIGHT"
    case organizationName = "ORGANIZATIONNAME"
    case projectName = "PROJECTNAME"
    case classPrefix = "CLASSPREFIX"
    
    // MARK: - File and Project Related
    case fileName = "FILENAME"
    case fileBaseName = "FILEBASENAME"
    case fileBaseNameAsIdentifier = "FILEBASENAMEASIDENTIFIER"
    case packageName = "PACKAGENAME"
    case productName = "PRODUCTNAME"
    case workspaceName = "WORKSPACENAME"
    
    // MARK: - Date and Time Related
    case date = "DATE"
    case time = "TIME"
    case year = "YEAR"
    case month = "MONTH"
    case day = "DAY"
    
    // MARK: - User and System Related
    case userName = "USERNAME"
    case companyIdentifier = "COMPANYIDENTIFIER"
    case developmentTeam = "DEVELOPMENTTEAM"
    
    // MARK: - Version and Build Related
    case version = "VERSION"
    case build = "BUILD"
    case targetName = "TARGETNAME"
    case platform = "PLATFORM"
    
    // MARK: - Swift and Development Related
    case swiftVersion = "SWIFTVERSION"
    case xcodeVersion = "XCODEVERSION"
    case deploymentTarget = "DEPLOYMENTTARGET"
    
    var id: String { rawValue }
    
    /// Human-readable name for the template key
    var displayName: String {
        switch self {
        case .fileHeader: return "File Header"
        case .fullUserName: return "Full User Name"
        case .copyright: return "Copyright"
        case .organizationName: return "Organization Name"
        case .projectName: return "Project Name"
        case .classPrefix: return "Class Prefix"
        case .fileName: return "File Name"
        case .fileBaseName: return "File Base Name"
        case .fileBaseNameAsIdentifier: return "File Base Name as Identifier"
        case .packageName: return "Package Name"
        case .productName: return "Product Name"
        case .workspaceName: return "Workspace Name"
        case .date: return "Date"
        case .time: return "Time"
        case .year: return "Year"
        case .month: return "Month"
        case .day: return "Day"
        case .userName: return "User Name"
        case .companyIdentifier: return "Company Identifier"
        case .developmentTeam: return "Development Team"
        case .version: return "Version"
        case .build: return "Build"
        case .targetName: return "Target Name"
        case .platform: return "Platform"
        case .swiftVersion: return "Swift Version"
        case .xcodeVersion: return "Xcode Version"
        case .deploymentTarget: return "Deployment Target"
        }
    }
    
    /// Detailed description of what this template key represents
    var description: String {
        switch self {
        case .fileHeader:
            return "The complete file header template that Xcode uses when creating new files. This is the main template that contains other placeholders."
            
        case .fullUserName:
            return "The full name of the current user as configured in the system (e.g., 'John Smith'). Retrieved from NSFullUserName()."
            
        case .copyright:
            return "Standard copyright notice text. Typically includes year and organization/user name (e.g., 'Copyright © 2023 Apple Inc.')."
            
        case .organizationName:
            return "Name of the organization or company. Used in copyright notices and file headers (e.g., 'Apple Inc.', 'My Company')."
            
        case .projectName:
            return "Name of the current Xcode project, derived from the .xcodeproj file name (e.g., 'MyApp', 'Calculator')."
            
        case .classPrefix:
            return "Prefix to be added to class names, commonly used in Objective-C projects (e.g., 'NS', 'UI', 'MY')."
            
        case .fileName:
            return "Complete filename including extension of the file being created (e.g., 'ViewController.swift', 'AppDelegate.m')."
            
        case .fileBaseName:
            return "Filename without the extension (e.g., 'ViewController' from 'ViewController.swift')."
            
        case .fileBaseNameAsIdentifier:
            return "Filename formatted as a valid programming identifier, with special characters removed or replaced."
            
        case .packageName:
            return "Name of the Swift package when working with Swift Package Manager projects."
            
        case .productName:
            return "Product name as defined in the build settings, which may differ from the project name."
            
        case .workspaceName:
            return "Name of the Xcode workspace (.xcworkspace) if the project is part of a workspace."
            
        case .date:
            return "Current date in the format configured by the system locale (e.g., '11/06/2025', '06/11/2025')."
            
        case .time:
            return "Current time in the format configured by the system locale (e.g., '2:30 PM', '14:30')."
            
        case .year:
            return "Current year as a 4-digit number (e.g., '2025')."
            
        case .month:
            return "Current month as a number (e.g., '11' for November)."
            
        case .day:
            return "Current day of the month as a number (e.g., '6')."
            
        case .userName:
            return "Short username of the current user, typically the login name (e.g., 'jsmith'). Retrieved from NSUserName()."
            
        case .companyIdentifier:
            return "Reverse domain name identifier for the company/organization (e.g., 'com.apple', 'com.mycompany')."
            
        case .developmentTeam:
            return "Apple Developer Team identifier used for code signing (e.g., 'ABCD123456')."
            
        case .version:
            return "Version number of the app as specified in build settings (e.g., '1.0', '2.1.3')."
            
        case .build:
            return "Build number of the app as specified in build settings (e.g., '1', '42', '2023.11.06')."
            
        case .targetName:
            return "Name of the current build target within the project (e.g., 'MyApp', 'MyAppTests')."
            
        case .platform:
            return "Target platform for the build (e.g., 'iOS', 'macOS', 'watchOS', 'tvOS')."
            
        case .swiftVersion:
            return "Version of Swift being used for compilation (e.g., '5.9', '6.0')."
            
        case .xcodeVersion:
            return "Version of Xcode being used for development (e.g., '15.0', '15.1')."
            
        case .deploymentTarget:
            return "Minimum version of the platform required to run the app (e.g., '14.0' for iOS 14.0, '11.0' for macOS 11.0)."
        }
    }
    
    /// Category grouping for UI organization
    var category: TemplateKeyCategory {
        switch self {
        case .fileHeader, .fullUserName, .copyright, .organizationName, .projectName, .classPrefix:
            return .core
        case .fileName, .fileBaseName, .fileBaseNameAsIdentifier, .packageName, .productName, .workspaceName, .targetName:
            return .fileAndProject
        case .date, .time, .year, .month, .day:
            return .dateAndTime
        case .userName, .companyIdentifier, .developmentTeam:
            return .userAndSystem
        case .version, .build, .platform:
            return .versionAndBuild
        case .swiftVersion, .xcodeVersion, .deploymentTarget:
            return .development
        }
    }
    
    /// Returns all template keys as an array of strings
    static var allKeys: [String] {
        return TemplateKeys.allCases.map { $0.rawValue }
    }
    
    /// Returns template keys grouped by category
    static var groupedByCategory: [TemplateKeyCategory: [TemplateKeys]] {
        return Dictionary(grouping: TemplateKeys.allCases) { $0.category }
    }
}

/// Categories for organizing template keys in the UI
enum TemplateKeyCategory: String, CaseIterable {
    case core = "Core"
    case fileAndProject = "File & Project"
    case dateAndTime = "Date & Time"
    case userAndSystem = "User & System"
    case versionAndBuild = "Version & Build"
    case development = "Development"
    
    var displayName: String {
        return rawValue
    }
    
    var description: String {
        switch self {
        case .core:
            return "Essential template macros including file header and basic project information"
        case .fileAndProject:
            return "File names, project structure, and workspace information"
        case .dateAndTime:
            return "Current date and time in various formats"
        case .userAndSystem:
            return "User account and system configuration information"
        case .versionAndBuild:
            return "App version, build numbers, and target platform"
        case .development:
            return "Development tools versions and deployment settings"
        }
    }
    
    /// Returns all template keys that belong to this category
    var templateKeys: [TemplateKeys] {
        switch self {
        case .core:
            return [
                .fileHeader,
                .fullUserName,
                .copyright,
                .organizationName,
                .projectName,
                .classPrefix
            ]
        case .fileAndProject:
            return [
                .fileName,
                .fileBaseName,
                .fileBaseNameAsIdentifier,
                .packageName,
                .productName,
                .workspaceName,
                .targetName
            ]
        case .dateAndTime:
            return [
                .date,
                .time,
                .year,
                .month,
                .day
            ]
        case .userAndSystem:
            return [
                .userName,
                .companyIdentifier,
                .developmentTeam
            ]
        case .versionAndBuild:
            return [
                .version,
                .build,
                .platform
            ]
        case .development:
            return [
                .swiftVersion,
                .xcodeVersion,
                .deploymentTarget
            ]
        }
    }
    
    /// Returns the count of template keys in this category
    var keyCount: Int {
        return templateKeys.count
    }
}
