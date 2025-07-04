//
//  ErrorBorder.swift
//  BodyFatCalculator
//
//  Created by Oncu Can on 4.07.2025.
//

import SwiftUI

struct ErrorBorder: ViewModifier {
    var isError: Bool

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isError ? .red : .clear, lineWidth: isError ? 2 : 0)
            )
            .animation(.easeOut(duration: 0.2), value: isError)
    }
}
