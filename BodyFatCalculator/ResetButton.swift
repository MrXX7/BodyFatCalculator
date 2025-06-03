//
//  ResetButton.swift
//  BodyFatCalculator
//
//  Created by Oncu Can on 3.06.2025.
//

import SwiftUI

struct ResetButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label("Reset All", systemImage: "arrow.counterclockwise.circle.fill")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orange)
                .cornerRadius(10)
        }
        .listRowBackground(Color.clear)
        .padding(.vertical)
    }
}

// MARK: - Preview Provider (Opsiyonel, SwiftUI Canvas için)
struct ResetButton_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            ResetButton(action: {
                print("Reset button tapped!")
            })
        }
    }
}
