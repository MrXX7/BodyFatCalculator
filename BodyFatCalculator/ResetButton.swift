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
                .background(Color.orange) // Distinct color for the reset button
                .cornerRadius(10)
        }
        .listRowBackground(Color.clear)
        .padding(.vertical)
    }
}

struct ResetButton_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            ResetButton(action: {
                print("Reset button tapped!")
            })
        }
    }
}
