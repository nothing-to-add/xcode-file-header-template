//
//  File name: TemplateRowView.swift
//  Project name: xcode-file-header-template
//  Workspace name: xcode-file-header-template
//
//  Created by: nothing-to-add on 03/11/2025
//  Using Swift 6.0
//  Copyright (c) 2023 nothing-to-add
//

import SwiftUI

struct TemplateRowView: View {
    let template: FileHeaderTemplate
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(template.name)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            
            Text(template.description)
                .font(.caption)
                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
        .background(isSelected ? Color.accentColor : Color.clear)
        .cornerRadius(6)
    }
}

#Preview {
    VStack(spacing: 8) {
        TemplateRowView(
            template: FileHeaderTemplate.defaultTemplates[0],
            isSelected: false
        )
        
        TemplateRowView(
            template: FileHeaderTemplate.defaultTemplates[1],
            isSelected: true
        )
    }
    .padding()
}
