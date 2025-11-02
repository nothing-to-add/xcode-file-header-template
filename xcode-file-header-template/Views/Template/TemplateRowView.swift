//
//  TemplateRowView.swift
//  xcode-file-header-template
//
//  Created by maksims.laitans on 03/11/2025.
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
    TemplateRowView()
}
