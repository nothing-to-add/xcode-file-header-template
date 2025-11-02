//
//  File name: EmptyMacrosView.swift
//  Project name: xcode-file-header-template
//  Workspace name: xcode-file-header-template
//
//  Created by: nothing-to-add on 03/11/2025
//  Using Swift 6.0
//  Copyright (c) 2023 nothing-to-add
//

import SwiftUI

struct EmptyMacrosView: View {
    let isGlobal: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: isGlobal ? "doc.text.badge.plus" : "folder.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No \(isGlobal ? "Global" : "Project") Macros")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(isGlobal
                     ? "Add template macros to customize Xcode's file headers globally"
                     : "Select a project and add project-specific template macros")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyMacrosView(isGlobal: true)
}
