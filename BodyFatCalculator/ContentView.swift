//
//  ContentView.swift
//  BodyFatCalculator
//
//  Created by Oncu Can on 22.05.2025.
//

import SwiftUI

struct ContentView: View {
    // MARK: - ViewModel Instance
    @StateObject private var viewModel = BodyFatCalculatorViewModel() // ViewModel'ı burada başlatıyoruz

    // MARK: - Focus State
    // Focused field hala ContentView'de kalmalı çünkü form genelindeki focus'u yönetiyor.
    @FocusState private var focusedField: Field?

    // MARK: - Enums (Needs to be here for FocusState to reference)
    // Field enum'ı FocusedState tarafından kullanıldığı için burada kalmalı.
    enum Field: Hashable {
        case weight, height, waist, neck, hip, age
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            Form {
                // Body Information Section (now a separate View)
                BodyInfoSection(viewModel: viewModel, focusedField: _focusedField)
                
                // Calculate Button
                Button(action: {
                    focusedField = nil // Dismiss keyboard
                    viewModel.calculateBodyFat() // Call ViewModel's calculate method
                }) {
                    Label("Calculate Body Fat", systemImage: "arrow.right.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("ButtonBlue"))
                        .cornerRadius(10)
                }
                .listRowBackground(Color.clear)
                .padding(.vertical)

                // Reset Button
                ResetButton(action: {
                    viewModel.resetAllFields() // Call ViewModel's reset method
                    focusedField = nil // Dismiss keyboard
                })
                .listRowBackground(Color.clear)

                // Results Section (now a separate View)
                ResultsSection(viewModel: viewModel)
            }
            .navigationTitle("Body Fat Calculator")
            .navigationBarTitleDisplayMode(.inline)
            .alert(item: $viewModel.activeAlert) { error in
                Alert(title: Text("Input Error"), message: Text(error.localizedDescription), dismissButton: .default(Text("OK"), action: {
                    // Highlight error field when alert is dismissed
                    viewModel.highlightErrorField(error: error)
                    // Set focus to the erroneous field
                    if let fieldId = error.fieldId {
                        switch fieldId {
                        case "weight": focusedField = .weight
                        case "height": focusedField = .height
                        case "waist": focusedField = .waist
                        case "neck": focusedField = .neck
                        case "hip": focusedField = .hip
                        case "age": focusedField = .age
                        default: break
                        }
                    }
                }))
            }
            .onTapGesture {
                focusedField = nil // Dismiss keyboard on tap outside of text fields
            }
            .background(Color(.systemGroupedBackground))
            .scrollContentBackground(.hidden)
        }
    }
}

// MARK: - Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
