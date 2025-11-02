//
//  File name: MacrosOverviewView.swift
//  Project name: xcode-file-header-template
//  Workspace name: xcode-file-header-template
//
//  Created by: nothing-to-add on 03/11/2025
//  Using Swift 6.0
//  Copyright (c) 2023 nothing-to-add
//

import SwiftUI

struct MacrosOverviewView: View {
    let macros: [String: String]
    let isGlobal: Bool
    let templateManager: TemplateManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(isGlobal ? "Global" : "Project") IDETemplateMacros")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Label(isGlobal ? "Global" : "Project",
                          systemImage: isGlobal ? "globe" : "folder")
                        .foregroundColor(isGlobal ? .blue : .green)
                }
                
                Text(isGlobal
                     ? "~/Library/Developer/Xcode/UserData/IDETemplateMacros.plist"
                     : "<ProjectPath>/IDETemplateMacros.plist")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textSelection(.enabled)
            }
            
            if macros.isEmpty {
                EmptyMacrosView(isGlobal: isGlobal)
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Select a macro from the sidebar to view and edit its details.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    GroupBox("Available Macros (\(macros.count))") {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(Array(macros.keys.sorted()), id: \.self) { key in
                                MacroSummaryCard(key: key, value: macros[key] ?? "")
                            }
                        }
                        .padding()
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
}


#Preview {
    MacrosOverviewView()
}
