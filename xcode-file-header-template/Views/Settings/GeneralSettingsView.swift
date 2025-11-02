//
//  GeneralSettingsView.swift
//  xcode-file-header-template
//
//  Created by maksims.laitans on 03/11/2025.
//

import SwiftUI

struct GeneralSettingsView: View {
    @Binding var defaultAuthor: String
    @Binding var defaultOrganization: String
    @Binding var defaultSwiftVersion: String
    @Binding var autoApplyTemplates: Bool
    @Binding var backupBeforeApply: Bool
    
    var body: some View {
        Form {
            Section("Default Values") {
                HStack {
                    Text("Author:")
                    TextField("Author name", text: $defaultAuthor)
                }
                
                HStack {
                    Text("Organization:")
                    TextField("Organization name", text: $defaultOrganization)
                }
                
                HStack {
                    Text("Swift Version:")
                    TextField("Swift version", text: $defaultSwiftVersion)
                }
            }
            
            Section("Behavior") {
                Toggle("Auto-apply templates to new files", isOn: $autoApplyTemplates)
                    .help("Automatically apply templates when creating new files")
                
                Toggle("Create backup before applying templates", isOn: $backupBeforeApply)
                    .help("Create .backup files before modifying existing files")
            }
        }
        .padding()
    }
}

#Preview {
    GeneralSettingsView()
}
