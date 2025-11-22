//
//  File name: MacrosListSectionView.swift
//  Project name: xcode-file-header-template
//  Workspace name: xcode-file-header-template
//
//  Created by: nothing-to-add on 22/11/2025
//  Using Swift 6.0
//  Copyright (c) 2023 nothing-to-add
//

import SwiftUI

struct MacrosListSectionView: View {
    @EnvironmentObject var templateManager: TemplateManager
    var isGlobal: Bool
    @Binding var selectedMacro: IDETemplateMacro?
    @Binding var editingMacro: IDETemplateMacro?
    
    var body: some View {
        List(selection: $selectedMacro) {
            if isGlobal {
                globalMacrosSection
            } else {
                projectMacrosSection
            }
        }
        .listStyle(SidebarListStyle())
    }
    
    private func macroSection(
        macros: [IDETemplateMacro],
        isGlobal: Bool,
        deleteMacro: @escaping (IDETemplateMacro) -> MacroResult
    ) -> some View {
        ForEach(macros, id: \.id) { macro in
            SelectableMacroRow(
                macro: macro,
                isBuiltIn: isGlobal && IDETemplateMacro.builtInMacros.contains { $0.name == macro.name },
                isSelected: selectedMacro == macro
            ) {
                editingMacro = macro
            } onDelete: {
                deleteMacro(macro)
                if selectedMacro == macro {
                    selectedMacro = nil
                }
            }
            .tag(macro)
        }
    }
    
    private var globalMacrosSection: some View {
        macroSection(
            macros: templateManager.globalMacros,
            isGlobal: true,
            deleteMacro: templateManager.deleteGlobalMacro
        )
    }
    
    private var projectMacrosSection: some View {
        macroSection(
            macros: templateManager.projectMacros,
            isGlobal: false,
            deleteMacro: templateManager.deleteProjectMacro
        )
    }
}

#Preview {
    @Previewable @State var selectedMacro: IDETemplateMacro? = nil
    @Previewable @State var editingMacro: IDETemplateMacro? = nil
    
    return MacrosListSectionView(
        isGlobal: true,
        selectedMacro: $selectedMacro,
        editingMacro: $editingMacro
    )
    .environmentObject(TemplateManager())
}
