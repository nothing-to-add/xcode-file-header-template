//
//  EmptySelectionView.swift
//  xcode-file-header-template
//
//  Created by maksims.laitans on 03/11/2025.
//

import SwiftUI

struct EmptySelectionView: View {
    let isGlobal: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Macro Selected")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Select a macro from the sidebar to view its details and edit options.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptySelectionView()
}
