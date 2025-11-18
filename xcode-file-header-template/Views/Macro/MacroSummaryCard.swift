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
    let macro: IDETemplateMacro
    let onTap: (() -> Void)?
    
    init(macro: IDETemplateMacro, onTap: (() -> Void)? = nil) {
        self.macro = macro
        self.onTap = onTap
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(macro.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Text(macro.name == "FILEHEADER" ? "File Header Template" : String(macro.value.prefix(60)))
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        MacroSummaryCard(macro: IDETemplateMacro(name: "FILEHEADER", value: "Example file header template content")) {
            print("FILEHEADER tapped")
        }
        MacroSummaryCard(macro: IDETemplateMacro(name: "PROJECTNAME", value: "xcode-file-header-template")) {
            print("PROJECTNAME tapped")
        }
        MacroSummaryCard(macro: IDETemplateMacro(name: "FILENAME", value: "MacroSummaryCard.swift")) {
            print("FILENAME tapped")
        }
        MacroSummaryCard(macro: IDETemplateMacro(name: "AUTHOR", value: "nothing-to-add")) {
            print("AUTHOR tapped")
        }
    }
    .padding()
}
