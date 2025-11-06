//
//  AboutView.swift
//  xcode-file-header-template
//
//  Created by maksims.laitans on 03/11/2025.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)
            
            VStack(spacing: 8) {
                Text("Xcode File Header Template")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Version 1.0.0")
                    .foregroundColor(.secondary)
                
                Text("A macOS application for managing Xcode file header templates")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 8) {
                Link("View on GitHub", destination: URL(string: "https://github.com/nothing-to-add/xcode-file-header-template")!)
                
                Text("Copyright © 2023 nothing-to-add")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    AboutView()
}
