//
//  File name: MacroEditSplitView.swift
//  Project name: xcode-file-header-template
//  Workspace name: xcode-file-header-template
//
//  Created by: nothing-to-add on 24/11/2025
//  Using Swift 6.0
//  Copyright (c) 2023 nothing-to-add
//

import SwiftUI

struct MacroEditSplitView: View {
    let macro: IDETemplateMacro?
    let isGlobal: Bool
    
    @State private var isEditing = false
    
    var body: some View {
        HStack {
            if let macro {
                SelectedMacroDetailView(
                    macro: macro
                )
                .frame(maxWidth: .infinity)
            } else {
                EmptySelectionView(isGlobal: true)
                    .frame(maxWidth: .infinity)
            }
            
            Divider()
            
            MacroEditorView(
                macro: macro,
                isGlobal: isGlobal
            )
            .frame(maxWidth: .infinity)
            .disabled(!isEditing)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(isEditing ? "Stop Editing" : "Start Editing") {
                    isEditing.toggle()
                }
                .buttonStyle(.borderedProminent)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isEditing ? Color.red : Color.blue)
                )
            }
        }
    }
}

#Preview {
    MacroEditSplitView(macro: IDETemplateMacro.getEmptyMacro(isGlobal: true), isGlobal: true)
}
