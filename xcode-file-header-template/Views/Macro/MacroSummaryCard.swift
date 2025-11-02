//
//  MacroSummaryCard.swift
//  xcode-file-header-template
//
//  Created by maksims.laitans on 03/11/2025.
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
    MacroSummaryCard()
}
