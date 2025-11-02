//
//  File name: MacroSummaryCard.swift
//  Project name: xcode-file-header-template
//  Workspace name: xcode-file-header-template
//
//  Created by: nothing-to-add on 03/11/2025
//  Using Swift 6.0
//  Copyright (c) 2023 nothing-to-add
//

import SwiftUI

struct MacroSummaryCard: View {
    let key: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(key)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Text(key == "FILEHEADER" ? "File Header Template" : String(value.prefix(60)))
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

#Preview {
    VStack(spacing: 16) {
        MacroSummaryCard(key: "FILEHEADER", value: "Example file header template content")
        MacroSummaryCard(key: "PROJECTNAME", value: "xcode-file-header-template")
        MacroSummaryCard(key: "FILENAME", value: "MacroSummaryCard.swift")
        MacroSummaryCard(key: "AUTHOR", value: "nothing-to-add")
    }
    .padding()
}
