//
//  File name: SelectableMacroRow.swift
//  Project name: xcode-file-header-template
//  Workspace name: xcode-file-header-template
//
//  Created by: nothing-to-add on 03/11/2025
//  Using Swift 6.0
//  Copyright (c) 2023 nothing-to-add
//

import SwiftUI
import CustomLogger

struct SelectableMacroRow: View {
    let macro: IDETemplateMacro
    let isBuiltIn: Bool
    let isSelected: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(macro.name)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    if isBuiltIn {
                        Text("Built-in")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(isSelected ? Color.white.opacity(0.2) : Color.blue.opacity(0.1))
                            .foregroundColor(isSelected ? .white : .blue)
                            .cornerRadius(4)
                    }
                }
                
                Text(macro.isFileHeaderMacro ? "File Header Template" : String(macro.value.prefix(40)))
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if !isBuiltIn {
                HStack(spacing: 8) {
                    Button {
                        onEdit()
                    } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(isSelected ? .white : .secondary)
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                    .help("Edit")
                    
                    Button {
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(isSelected ? .white : .red)
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                    .help("Delete")
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isSelected ? Color.accentColor : Color.clear)
        .cornerRadius(8)
    }
}

#Preview {
    VStack(spacing: 8) {
        SelectableMacroRow(
            macro: IDETemplateMacro(name: "PROJECT_NAME", value: "MyAwesomeProject"),
            isBuiltIn: true,
            isSelected: false,
            onEdit: { Logger.shared.info("Edit tapped") },
            onDelete: { Logger.shared.info("Delete tapped") }
        )
        
        SelectableMacroRow(
            macro: IDETemplateMacro(name: "CUSTOM_MACRO", value: "This is a custom macro with some longer text to test truncation"),
            isBuiltIn: false,
            isSelected: true,
            onEdit: { Logger.shared.info("Edit tapped") },
            onDelete: { Logger.shared.info("Delete tapped") }
        )
        
        SelectableMacroRow(
            macro: IDETemplateMacro(name: "FILEHEADER", value: "File Header Template Content"),
            isBuiltIn: true,
            isSelected: false,
            onEdit: { Logger.shared.info("Edit tapped") },
            onDelete: { Logger.shared.info("Delete tapped") }
        )
    }
    .padding()
}
