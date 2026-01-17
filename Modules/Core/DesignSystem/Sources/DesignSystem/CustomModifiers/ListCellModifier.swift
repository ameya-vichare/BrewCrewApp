//
//  ListCellModifier.swift
//  DesignSystem
//
//  Created by Ameya on 17/01/26.
//

import SwiftUI

struct ListCellModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowSeparator(.hidden)
            .listRowBackground(AppColors.clear)
            .listRowInsets(
                EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            )
    }
}

extension View {
    public func listCellStyle() -> some View {
        content
            .listRowSeparator(.hidden)
            .listRowBackground(AppColors.clear)
            .listRowInsets(
                EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            )
    }
}
