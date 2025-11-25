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
            
            if isNotFileHeaderMacro {
                Divider()
                
                MacroEditorView(
                    macro: macro,
                    isGlobal: isGlobal
                )
                .frame(maxWidth: .infinity)
                .disabled(!isEditing)
            }
        }
        .navigationTitle("Xcode Template Macro Overview" + (isNotFileHeaderMacro ? " and Editor" : ""))
        .toolbar {
            if isNotFileHeaderMacro {
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
            } else {
                ToolbarItem(placement: .primaryAction) {
                    Text("Built-in template can't be edited")
                        .font(.headline)
                        .foregroundStyle(.red)
                }
            }
        }
    }
    
    private var isNotFileHeaderMacro: Bool {
        macro?.isFileHeaderMacro == false
    }
}

#Preview {
    MacroEditSplitView(macro: IDETemplateMacro.getEmptyMacro(isGlobal: true), isGlobal: true)
}
