//
//  File name: MacroDetailRow.swift
//  Project name: xcode-file-header-template
//  Workspace name: xcode-file-header-template
//
//  Created by: nothing-to-add on 03/11/2025
//  Using Swift 6.0
//  Copyright (c) 2023 nothing-to-add
//

import SwiftUI

struct MacroDetailRow: View {
    let key: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(key)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if key == "FILEHEADER" {
                    Text("Header Template")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.purple.opacity(0.1))
                        .foregroundColor(.purple)
                        .cornerRadius(4)
                }
            }
            
            Text(value)
                .font(.system(.body, design: .monospaced))
                .padding(8)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
        }
    }
}

#Preview {
    MacroDetailRow(
        key: "FILEHEADER",
        value: "//\n//  ___FILENAME___\n//  ___PROJECTNAME___\n//\n//  Created by ___FULLUSERNAME___ on ___DATE___.\n//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.\n//"
    )
}
