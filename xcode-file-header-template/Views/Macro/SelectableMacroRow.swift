//
//  SelectableMacroRow.swift
//  xcode-file-header-template
//
//  Created by maksims.laitans on 03/11/2025.
//

import SwiftUI

struct SelectableMacroRow: View {
    let key: String
    let value: String
    let isBuiltIn: Bool
    let isSelected: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(key)
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
                
                Text(key == "FILEHEADER" ? "File Header Template" : String(value.prefix(40)))
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Menu {
                Button("Edit") { onEdit() }
                if !isBuiltIn {
                    Button("Delete", role: .destructive) { onDelete() }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .menuStyle(BorderlessButtonMenuStyle())
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isSelected ? Color.accentColor : Color.clear)
        .cornerRadius(8)
    }
}

#Preview {
    SelectableMacroRow()
}
